class Schedule < Hyperloop::Component

  # Scheduling options
  CRONTAB_SPRINKLE_ALL  = 0
  DAEMON_MINUTE_HAND  = 1

  before_mount do
    # any initialization particularly of state variables goes here.
    # this will execute on server (prerendering) and client.

    @schedulers = %w{ crontab minute_hand }
    @colors = %w{ btn-info btn-warning }
  end

  # defines color of button for each state (0/1)
  def color
    @colors[WaterManager.first.scheduling_option]
  end

  # defines the schedule text for each schedule (0/1)
  def scheduler
    @schedulers[WaterManager.first.scheduling_option]
  end

   # call to ServerOp (WaterManagerServer) which changes the server state in accordance with the state variable
  def toggle_scheduler
    new_scheduler = WaterManager.first.scheduling_option == CRONTAB_SPRINKLE_ALL ? DAEMON_MINUTE_HAND : CRONTAB_SPRINKLE_ALL
    WaterManager.first.update(scheduling_option: new_scheduler)
  end

  def render
    LI do
      title = "Scheduling option is #{scheduler}"
      BUTTON(class: "btn #{color} navbar-btn", data: { toggle: "tooltip"  }, title: title) do
        scheduler
      end.on(:click) {toggle_scheduler}
    end
  end

end 