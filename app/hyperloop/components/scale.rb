

class Scale < Hyperloop::Component

  def render
    LI do
      title = "scale"
      BUTTON(class: "btn btn-info navbar-btn", data: { toggle: "tooltip"  }, title: title) do
        "scale"
      end
    end
  end

end 