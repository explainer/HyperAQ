class PorterStatus < Hyperloop::Component

  after_mount do
    # This request will cause the 'get' method of the PortersController to 
    # access the request.port out of the http request and stash it into Porter.first.port_number.
    # That same method will grab the `hostname` from the underlying OS and stash it
    # into Porter.first.host_name
    # while Porter.first.host_with_port == "not-yet-loaded:9999"
      HTTP.get("/porters/1", dataType: "json").then do |response|
        # We don't care about the response, but the Porter.first object is now set up.
        puts "**************"
        puts response.json[:body]
        puts "**************"
      end
      sleep(1)
    # end
  end

  def render
    title = 'host:port'
    UL(class: 'navbar-header') do
      LI do
        BUTTON(class: "btn btn-info navbar-btn", data: { toggle: "tooltip", placement: "right" }, title: title) do
          Porter.first.host_with_port 
        end
      end
    end
  end
end


