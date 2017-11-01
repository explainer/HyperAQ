class TitleNav < Hyperloop::Component

  def render
  
    UL(class: 'navbar-nav') do
      LI do
        A(class: 'navbar-brand') do
          advertisement
        end       
      end
    end
  end

  def advertisement
    "Aquarius Sprinkler System, with Hyperloop UI, #{WaterManager.scheduler} scheduling, now with tooltips!"
  end

end

