require 'models/application_record'
class MinuteHand < ApplicationRecord

  if RUBY_ENGINE != 'opal'

    LOGFILE = "log/minute_hand.log"
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

    # 
    # check to see if any sprinkles are ready to be started or stopped
    #
    def manipulate_and_update(params)
      key = params[:key]
      log "key --> #{key}\n"
      log "WaterManager.first.key --> #{WaterManager.first.key}\n"
      
      t = Time.now
      reference_time = Time.new(t.year, t.mon, t.mday, t.hour, t.min, 0)

      log "MinuteHand.find(1).manipulate_and_update, time --> #{reference_time.strftime(LOG_TIME)}\n"

      # if key == WaterManager.first.key # do this only if the incoming key matches the master key

        #iterate through sprinkles table... 
        Sprinkle.all.each do |sprinkle|
          sprinkle.minute_hand_start if sprinkle.start_time == reference_time
          sprinkle.minute_hand_stop  if sprinkle.stop_time  == reference_time
          return true if sprinkle.start_time > reference_time  # no more sprinkles will match, so stop now
        end
      # end
      return true
    end

  end # RUBY_ENGINE

end
