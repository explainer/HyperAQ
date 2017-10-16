require 'models/sprinkle'
require 'models/valve'
require 'time'

class SprinkleRow < Hyperloop::Component
  param :sprinkle
    
  # Sprinkle states
  IDLE = 0
  ACTIVE = 1
  NEXT = 2

  SPRINKLE_TIME_FORMAT = "%a %d %b %l:%M %P"

  render do
    TR(class: markup) do
      TD { params.sprinkle.start_time.strftime(SPRINKLE_TIME_FORMAT) }

      TD { params.sprinkle.stop_time.strftime(SPRINKLE_TIME_FORMAT) }
    
      TD { params.sprinkle.time_input }    
    
      TD { params.sprinkle.duration.to_s }
    
      TD { params.sprinkle.valve.name }
    end
  end

  # change color as sprinkle state changes, using bootstrap classes
  def markup
    #   IDLE    ACTIVE NEXT
    %w{ default info   danger }[params.sprinkle.state]
  end

end