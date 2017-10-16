class TitleNav < Hyperloop::Component

  def render
    UL(class: 'navbar-header') do
      LI do
        A(class: 'navbar-brand', href: "#") do
          advertisement
        end       
      end
    end
  end

  def advertisement
    "Aquarius Sprinkler System, with Hyperloop UI, #{WaterManager.scheduler} scheduling, now with tooltips!"
  end

end

