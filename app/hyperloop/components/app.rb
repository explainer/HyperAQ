
  class App < Hyperloop::Component

    # The top of the component tree.
    # All components are free to use the Bootstrap styling library, installed as a CDN in app/views/layouts/application.html.erb

    def render
      UL do
        Navbar {}
        Layout {}
      end
      # .while_loading do # while loading displays while waiting for hyperloop to load data from server!
      #   DIV { "loading..." } # or whatever you want in here
      # end
    end
  end

