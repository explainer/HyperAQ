#/app/hyperloop/components/navbar.rb

class Navbar < Hyperloop::Component
  
  render(NAV) do
    NAV(class: 'navbar navbar-default') do
      DIV(class: 'container-fluid') do
        ControlButtons {}
        TitleNav {}
        ValveButtons {}
      end
    end
  end

end
