

class Demo < Hyperloop::Component

  def render
    LI do
      title = "demo"
      BUTTON(class: "btn btn-info navbar-btn", data: { toggle: "tooltip"  }, title: title) do
        "demo"
      end
    end
  end

end 