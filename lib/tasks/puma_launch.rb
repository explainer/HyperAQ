require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
#
# A ruby script to create the following command:
#
# puma_launch command [start|stop] --environment [DEVELOPMENT|production|test] --port nn [2017|9292]  --daemon
#
#  Example: ./lib/tasks/puma_launch.rb start --environment production --port 9292 --daemon --pidfile <<file path>>  # production 
#           ./lib/tasks/puma_launch.rb start   #default development
#           ./lib/tasks/puma_launch.rb stop  --pidfile <<file path>> 
#
# This is a simple ruby script to manage the start/stop of a rails app with the puma web server 
#
#    puma always uses --daemon mode, so --deamon is defaulted to 'true'.
#    a pid file is always used and the pidfile is always in the pids folder ($Rails.root.pids) , 
#      and named "#{environment}-#{port}.pid"
#    By personal convention, development and test mode use port 2017, while production uses 9292
#    the default environment is "development"
#
#    Therefore, the simplest form(s) of this command are "puma_launch start", and puma_launch stop
#
# This command MUST be launched from the root folder of the rails app.

ENVIRONMENTS = %w[development test production]
ENVIRONMENT_ALIASES = { "d" => "development", "t" => "test", "p" => "production" }

COMMANDS = %w[start stop]

DAEMONS = %w[true false]
DAEMON_ALIASES = { 't' => 'true', 'f'=> 'false'}

class PumaOptions
  attr_accessor :library, :environment, :port, :daemon, :pidfile

  Version = '0.10.0'

  def initialize
    self.library = []
    #
    # PumaOptions
    #
    self.environment = "development"
    self.port = 2017
    self.daemon = true
    self.pidfile = nil
  end

  def define_options(parser)
    parser.banner = "Usage: example.rb [options]"
    parser.separator ""
    parser.separator "Specific options:"

    # PumaLaunch-specific initializers

    set_environment(parser)
    set_port(parser)
    set_daemon(parser)
    set_pidfile(parser)
  
    parser.separator ""
    parser.separator "Common options:"
    # No argument, shows at tail.  This will print an options summary.
    # Try it and see!
    parser.on_tail("-h", "--help", "Show this message") do
      puts parser
      exit
    end
    # Another typical switch to print the version.
    parser.on_tail("--version", "Show version") do
      puts Version
      exit
    end
  end

  # PumaLaunch-specific options

  def set_environment(parser)
    # Keyword completion.  We are specifying a specific set of arguments (ENVIRONMENTS
    # and ENVIRONMENT_ALIASES - notice the latter is a Hash), and the user may provide
    # the shortest unambiguous text.
    env_list = (ENVIRONMENT_ALIASES.keys + ENVIRONMENTS).join(', ')
    parser.on("--environment ENVIRONMENT", 
              ENVIRONMENTS, ENVIRONMENT_ALIASES, 
              "Select environment",
              "(#{env_list})") do |environment|
      self.environment = environment
    end
  end

  def set_port(parser)
    # Cast 'port' argument to an Integer object.
    parser.on("-p", "--port [PORT]", Integer, "Define port number") do |port|
      self.port = port
    end
  end

  def set_daemon(parser)
    daemon_list = (DAEMON_ALIASES.keys + DAEMONS).join(', ')
    parser.on("-d", "--daemon [BOOLEAN]", DAEMONS, DAEMON_ALIASES, "Select daemon option") do |daemon|
      if daemon == 'true'
        self.daemon = true
      else
        self.daemon = false
      end
    end
  end

  def set_pidfile(parser)
    parser.on("f", "--pidfile [PIDFILE]", String, "Set pidfile name") do |pidfile|
      self.pidfile = pidfile
    end
  end
end # class PumaOptions

class PumaLaunch
  def initialize
    # log "location --> #{Dir.pwd}\n"
    @location = Dir.pwd
  end

  LOGFILE = "log/puma_launch.log"
  # LOG_TIME = "%H:%M:%S"

  # def log_time
  #   Time.now.strftime(LOG_TIME)
  # end

  def log(msg)
    f = File.open(LOGFILE, 'a')
    f.write msg
    # f.write "#{log_time} #{msg}"
    f.close
  end

  def location
    # log "location --> #{@location}\n"
    @location
  end

  def valid_location
    if File.exist?("#{location}/Gemfile")
      if !Dir.exist?("#{location}/tmp/pids")
        Dir.mkdir("#{location}/tmp/pids")
      end
      answer = true
    else
      answer = false
    end
    answer
  end

  #
  # Return a class describing the options.
  #
  def parse(args)
    # The options specified on the command line will be collected in
    # *options*.

    @options = PumaOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end
    @options
  end

  attr_reader :parser, :options, :command, :script

  def command
    if ARGV.length > 1
      puts "More than one command in input, exiting"
      exit
    end
    ARGV[0] ||= 'start'
    # puts "ARGV --> #{ARGV}"
    # puts "COMMANDS --> #{COMMANDS}"
    hit = false
    COMMANDS.each do |match|
      if match == ARGV[0]
        hit = true
      end
    end
    if !hit
      puts "Unrecognized command '#{ARGV[0]}', exiting"
      exit
    end
    ARGV[0] 
  end

  def environment_component
    "--environment #{self.options.environment}"
  end

  def pid_component
    if self.options.pidfile
      answer = "--pidfile #{self.options.pidfile}"
    else
      answer = "--pidfile #{rails_root}/tmp/pids/#{self.options.environment}-#{self.options.port}.pid"
    end
    answer
  end

  def daemon_component
    if self.options.daemon
      "--daemon"
    else
      ''
    end
  end

  def port_component
    if self.options.environment == 'production'
      self.options.port = 9292
    end
    "--port #{self.options.port}"
  end

  def rails_root
    Dir.pwd
  end

  def script
    if command == 'start'
      "puma #{environment_component} #{daemon_component} #{port_component} #{pid_component}"
    else
      "pumactl #{pid_component} #{command}"
    end
  end
end  # class PumaLaunch

# Main program

launcher = PumaLaunch.new
if launcher.valid_location
  options = launcher.parse(ARGV)
  pp launcher.script
  exec(launcher.script)
else
  puts "This command MUST be invoked from a Rails root folder"
end

