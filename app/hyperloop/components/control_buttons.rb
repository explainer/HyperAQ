#/app/hyperloop/components/control_buttons.rb

class ControlButtons < Hyperloop::Component

  def render
    UL(class: 'nav navbar-nav') do
      PorterStatus {}
      WaterStatus {}
      Demo {}
      Schedule {}
      Scale {}
    end
  end
end
