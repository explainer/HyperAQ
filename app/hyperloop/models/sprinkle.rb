require 'time'
require 'json'
require 'models/application_record'

class Sprinkle < ApplicationRecord
  default_scope { order(start_time: :asc) }

  belongs_to :valve
  
  validates :time_input, :duration, :valve_id, presence: true

  def stop_time
    start_time + duration * 60
  end
                                                        
  if RUBY_ENGINE != 'opal'
    #   SU  MO  TU  WE  TH  FR  SA
    DAY_OF_WEEK_MAP =[
      [ 0,  6,  5,  4,  3,  2,  1 ], # SU
      [ 1,  0,  6,  5,  4,  3,  2 ], # MO
      [ 2,  1,  0,  6,  5,  4,  3 ], # TU
      [ 3,  2,  1,  0,  6,  5,  4 ], # WE
      [ 4,  3,  2,  1,  0,  6,  5 ], # TH
      [ 5,  4,  3,  2,  1,  0,  6 ], # FR
      [ 6,  5,  4,  3,  2,  1,  0 ]  # SA
    ]
    # useful time constants
    SECONDS_PER_HOUR = 60*60
    SECONDS_PER_DAY = 24*SECONDS_PER_HOUR
    SECONDS_PER_WEEK = SECONDS_PER_DAY * 7

    TIME_INPUT_STRFTIME = "%a %d %b %l:%M %P"

    CRONTAB_STRFTIME = "%02M %02k * * %w"

    # Valve cmd states
    ON = 1
    OFF = 0

    # Sprinkle states
    IDLE = 0
    ACTIVE = 1
    NEXT = 2

    # LOGFILE = "log/sprinkle.log"
    # LOG_TIME = "%H:%M:%S "

    # def log_time
    #   Time.now.strftime(LOG_TIME)
    # end

    # def log(msg)
    #   f = File.open(LOGFILE, 'a')
    #   f.write msg
    #   f.write "#{log_time} #{msg}"
    #   f.close
    # end

    #
    # business logic methods
    #

    # answer a Time object representing the next start_time
    def next_start_time
      # merge the schedule weekday, hour and minute with today's year, month, weekday to form the next start_time
      t = Time.now
      s = DateTime.parse(time_input)
      answer = Time.new(t.year, t.mon, t.mday, s.hour, s.min, 0)

      # adjust weekday so the answer weekday aligns with time_input weekday
      answer += DAY_OF_WEEK_MAP[s.wday.pred][answer.wday.pred] * SECONDS_PER_DAY
      if answer < Time.now
        # in the past, so add a week        
        answer += SECONDS_PER_WEEK
      end
      answer
    end

    def manipulate_and_update(params)
      # Parameters: {"state"=>"0", "id"=>"9", "sprinkle"=>{"state"=>"0"}}
      new_state = params['state'].to_i
      
      # log "sprinkle.manipulate_and_update(params)\n"
      # log "new_state --> #{states(new_state)}\n"
      # log "id --> #{id}\n"
      # log "sprinkle.state (old) --> #{states(state)}\n"
      # log "sprinkle.state (new) --> #{states(new_state)}\n"

      if new_state == ACTIVE # start valve sequence
        start
      else # stop valve sequence
        stop      
      end   
      true # must return true
    end

    def start
      update(state: ACTIVE)
      # log "sprinkle.start #{valve.name}, #{state} #{states(state)}\n"
      if valve.cmd != ON
        valve.start
      end
    end

    def stop
      valve.stop      
      update(state: IDLE)
      # log "sprinkle.stop #{valve.name}, #{state} #{states(state)}\n"
      move_to_next_start_time
      #update(start_time: next_start_time)
      mark_next
      # Finally, prune any History(List) entries older than the PRUNE_INTERVAL
      # List.prune  Ok   
    end

    def minute_hand_start
      start if state != ACTIVE
    end

    def minute_hand_stop
      stop if state == ACTIVE
    end

    def move_to_next_start_time
      Sprinkle.where("start_time < ?", Time.now).each do |sprinkle|
        sprinkle.update(start_time: sprinkle.start_time + SECONDS_PER_WEEK, state: IDLE)
      end
    end

    def mark_next
      # Mark the first row in the sprinkle table NEXT
      Sprinkle.first.update(state: NEXT) if Sprinkle.first.state != ACTIVE
    end

    #answer a string formatted to crontab time standards.  Answer start_time if state is 1 (ACTIVE),
    #answer stop_time if state is 0 (IDLE)
    def to_crontab_time(state)
      # log "Sprinkle.to_crontab(#{state})\n"
      if state == ACTIVE
        t = start_time
        # log "start_time --> #{t}, #{t.strftime(CRONTAB_STRFTIME)}\n"
      else
        t = stop_time
        # log "stop_time --> #{t}, #{t.strftime(CRONTAB_STRFTIME)}\n"
      end
      t.strftime(CRONTAB_STRFTIME)
    end

    # answer a set of attributes as a string containing the 2 attributes in order
    def to_crontab_attributes(state)
      "#{id} #{state}"
    end

    def actuator_path
      File.realdirpath('lib/tasks/sprinkle_actuator.sh')
    end

    private
      def states(index)
        %w{ IDLE ACTIVE NEXT }[index]
      end

      def time_as_string(t)
        t.strftime(TIME_INPUT_STRFTIME)
      end

  end # RUBY_ENGINE


end
