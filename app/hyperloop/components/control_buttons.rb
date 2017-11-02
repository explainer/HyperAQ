#/app/hyperloop/components/control_buttons.rb

# Scheduling options
CRONTAB_SPRINKLE_ALL  = 0
DAEMON_MINUTE_HAND  = 1

# System Watering states
WM_ACTIVE =  1
WM_STANDBY = 0



class ControlButtons < Hyperloop::Component

  def render
    UL(class: 'nav navbar-nav') do
      PorterStatus {}
      WaterStatus {}
      if WaterManager.first.state == WM_STANDBY
        Demo {}
        Schedule {}
        if WaterManager.first.scheduling_option == DAEMON_MINUTE_HAND
          Scale {}
        end
      end
    end
  end
end
