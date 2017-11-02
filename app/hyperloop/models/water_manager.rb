require 'models/application_record'
class WaterManager < ApplicationRecord
  # Scheduling options
  CRONTAB_SPRINKLE_ALL  = 0
  DAEMON_MINUTE_HAND  = 1

  def self.scheduler
    ["crontab", "minute hand"][WaterManager.first.scheduling_option]
  end

  def self.scheduling_options
    [CRONTAB_SPRINKLE_ALL, DAEMON_MINUTE_HAND ][WaterManager.first.scheduling_option]
  end

  def self.singleton
    WaterManager.first
  end


end 
