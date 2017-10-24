require 'models/application_record'
class List < ApplicationRecord # Treat this as History, since Opal inflection problems broke with 'History', but work with 'List'

  default_scope { order(start_time: :desc) } # keep in sorted order, with the last created List at the top.
  belongs_to :valve

  LOGFILE = "log/history.log"
  LOG_TIME = "%H:%M:%S "

  def log_time
    Time.now.strftime(LOG_TIME)
  end

  def log(msg)
    f = File.open(LOGFILE, 'a')
    # f.write msg
    f.write "#{log_time} #{msg}"
    f.close
  end

  SECONDS_PER_HOUR = 60*60
  SECONDS_PER_DAY = 24*SECONDS_PER_HOUR
  SECONDS_PER_WEEK = SECONDS_PER_DAY * 7
  PRUNE_INTERVAL = SECONDS_PER_WEEK 
  TIME_INPUT_STRFTIME = "%a %d %b %l:%M %P"

  # Create an instance of History, using valve_id of the owning valve_id as initialization parameter
  def start(valve_id)
    valve = Valve.find(valve_id)
    log "history.start: #{valve.name}, "
    update(start_time: Time.now, valve_id: valve_id)
    valve.update(active_history_id: id)
  end

  # Complete the history
  def stop
    valve = Valve.find(valve_id)
    log "history.stop: #{valve.name}\n"
    update(stop_time: Time.now)
    valve.update(active_history_id: 0)
  end

  # Delete entries older than Time.now - PRUNE_INTERVAL
  def self.prune
    lists = List.all.reverse # work from oldest back
    lists.each do |list|
      if (Time.now - list.start_time) > PRUNE_INTERVAL
        list.delete
      else
        return # once you get a non-match, quit
      end
    end
  end

end
