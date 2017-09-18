require 'models/application_record'
class List < ApplicationRecord # Treat this as History, since Opal inflection problems broke with 'History', but work with 'List'

  # you can just specify how the stuff should be sorted in the default scope.
  # if you for some reason have different sort orders just define different scopes.

  default_scope { order(start_time: :desc) }
  belongs_to :valve

  SECONDS_PER_HOUR = 60*60
  SECONDS_PER_DAY = 24*SECONDS_PER_HOUR
  SECONDS_PER_WEEK = SECONDS_PER_DAY * 7
  PRUNE_INTERVAL = 1 * SECONDS_PER_WEEK 
  TIME_INPUT_STRFTIME = "%a %d %b %l:%M %P"

  # Create an instance of History, using valve_id of the owning Valve as initialization parameter
  def self.start(valve)
    List.create(start_time: Time.now, start_time_display: Time.now.strftime(TIME_INPUT_STRFTIME), stop_time_display: ' ', valve_id: valve.id)
  end

  # Complete the history
  def stop
    update(stop_time_display: Time.now.strftime(TIME_INPUT_STRFTIME))
  end

  # Delete entries older than Time.now - PRUNE_INTERVAL
  def self.prune
    if List.count > 60
      List.all.each do |list|
        if list.start_time < Time.now - PRUNE_INTERVAL
          list.delete
        end
      end
    end
  end
end
