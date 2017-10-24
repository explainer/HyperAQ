class SchedulingService
  def start
  end

  def stop
  end

  LOGFILE = "log/scheduling_service.log"
  LOG_TIME = "%H:%M:%S"

  def log_time
    Time.now.strftime(LOG_TIME)
  end

  def log(msg)
    f = File.open(LOGFILE, 'a')
    f.write "#{log_time} #{msg}"
    f.close
  end
end

class MinuteHandService < SchedulingService
  def start
    # logger.debug "MinuteHandService.new.start"
    log "Starting minute hand daemon\n"
    spawnee = "ruby #{actuator_path} #{scale_factor} #{Porter.first.localhost_with_port} #{WaterManager.first.key} #{File.realdirpath('lib/tasks/minute_hand_actuator.sh')}"
    log "spawn #{spawnee}\n"
    pid = 12345
    pid = Process.spawn(spawnee)
    f = File.open(pid_file_name, 'w')
    f.write pid.to_s
    log "pid file --> #{pid_file_name}, pid --> #{pid}\n"
    f.close
    # logger.debug "MinuteHandService.new.start completed"
  end

  def stop
    # logger.debug "MinuteHandService.new.stop"
    log "Stopping minute hand daemon\n"
    lines = File.readlines(pid_file_name)
    system("rm #{pid_file_name}")
    pid = lines[0].to_i
    system("kill -KILL #{pid}")
    log "kill pid #{pid}\n"
    # logger.debug "MinuteHandService.new.stop completed"
  end

  private
    def actuator_path
      File.realdirpath('lib/tasks/minute_hand_daemon.rb')
    end

    def scale_factor
      1
    end

    def pid_file_name
      'tmp/pids/minute_hand_daemon.pid'
    end
end

class CrontabService < SchedulingService
  # Sprinkle states
  IDLE = 0
  ACTIVE = 1
  NEXT = 2

  def start
    # create a working crontab file
    log "Building crontab\n"
    f = File.open(crontab_file, 'w')
    f.write "MAIL='keburgett@gmail.com'\n"
    # for each sprinkle, write a crontab entry for ON and OFF times.
    p = Porter.first.localhost_with_port # provides host:port combination
    sprinkle_agent_id = 99 # fUture update to use daemon, for now just a placeholder
    Sprinkle.all.each do |s|
      [ACTIVE, IDLE].each do |state| # Note that valve states and sprinkles states SHARE the same numeric values
        crontab_line =  "#{s.to_crontab_time(state)} sh #{s.actuator_path} #{p} #{s.to_crontab_attributes(state)}\n" 
        f.write crontab_line
        log "#{crontab_line}"
      end
    end
    f.close
    system("crontab #{crontab_file}")
    log "crontab deployed\n"
    # Mark the first Sprinkle NEXT
    # Sprinkle.first.update(state: NEXT)
  end

  def stop
    log "Removing crontab\n"
    system("crontab -r")
    system("touch lib/assets/crontab")
    system("rm lib/assets/crontab")
  end  

  private
    def crontab_file
      'lib/assets/crontab'
    end
end

class WaterManagerServer < Hyperloop::ServerOp
  param :acting_user, nils: true
  param :wm_id #, type: Number
  dispatch_to { Hyperloop::Application }

  step do 
    water_manager_update(params.wm_id)
  end

  # System Watering states
  WM_ACTIVE =  1
  WM_STANDBY = 0

  # states = %w{ Standby Active }

  # Valve command values
  OFF = 0
  ON = 1

  # Scheduling options
  CRONTAB_SPRINKLE_ALL  = 0
  DAEMON_MINUTE_HAND  = 1

  # CRONTAB = 'lib/assets/crontab'

  TIME_INPUT_STRFTIME = "%a %d %b %l:%M %P"

  LOGFILE = "log/water_manager_server.log"
  LOG_TIME = "%H:%M:%S"

  def log_time
    Time.now.strftime(LOG_TIME)
  end

  def log(msg)
    f = File.open(LOGFILE, 'a')
    # f.write msg
    f.write "#{log_time} #{msg}"
    f.close
  end

  def water_manager_update(id)
    log "WaterManagerServer.water_manager_update(#{id})\n"
    wm = WaterManager.find(id)
    # toggle state
    wm.update(state: (wm.state == WM_ACTIVE ? WM_STANDBY : WM_ACTIVE))
    
    if wm.state == WM_ACTIVE
      log "wm.arm\n"
      arm
    else
      log "wm.disarm\n"
      disarm
    end
  end

  def scheduling_options
    %w{ CRONTAB_SPRINKLE_ALL DAEMON_MINUTE_HAND }[WaterManager.first.scheduling_option]
  end

  def arm
    log "Set up scheduling option: #{scheduling_options}\n"
    case WaterManager.first.scheduling_option
    when CRONTAB_SPRINKLE_ALL
      # install_crontab
      CrontabService.new.start
    when DAEMON_MINUTE_HAND
      # install_minute_hand_daemon
      MinuteHandService.new.start
    end
    # Mark the first Sprinkle NEXT
    # Sprinkle.first.update(state: NEXT) #test for 500
  end

  def disarm
    log "Shut down scheduling option: #{scheduling_options}\n"
    case WaterManager.first.scheduling_option
    when CRONTAB_SPRINKLE_ALL
      # remove_crontab
      CrontabService.new.stop
    when DAEMON_MINUTE_HAND
      # remove_minute_hand_daemon
      MinuteHandService.new.stop
    end

    # close all valves
    Valve.all.each do |v|
      # close only those valves that are open.
      if v.cmd == ON
        v.command(OFF)
      end
    end
  end
end 

