class WaterStatus < Hyperloop::Component
    
  before_mount do
    # any initialization particularly of state variables goes here.
    # this will execute on server (prerendering) and client.

    @states = %w{ Standby Active }
    @colors = %w{ btn-info btn-warning }
  end

  # defines color of button for each state (0/1)
  def color
    @colors[WaterManager.first.state]
  end

  # defines the state text for each state (0/1)
  def state
    @states[WaterManager.first.state]
  end

   # call to ServerOp (WaterManagerServer) which changes the server state in accordance with the state variable
  def toggle_state
    WaterManagerServer.run(wm_id: WaterManager.first.id)
  end

  def render
    title = "System is in #{state} mode"
    LI do
      BUTTON(class: "btn #{color} navbar-btn", data: { toggle: "tooltip" }, title: title) do 
        state
      end.on(:click) { toggle_state }
    end
  end

end

