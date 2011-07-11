#
# Place methods here that you want available to you in your views.
# View helpers allow you keep templates clean.
#
module ViewHelpers
  
  # Example helper method
  def hello(name)
    "Hello \#{name}!"
  end
  
  # Handy for hiding a block of unfinished code
  def hidden(&block)
    #no-op
  end
  
  # Shorthand for referencing images in the images folder
  def image(name, options = {})
    path = "/images/\#{name}"
    path += ".png" unless path.match(/\.[A-za-z]{3,4}$/)
    image_tag(name, {:alt => ""}.update(options))
  end
  
  # Calculate the years for a copyright
  def copyright_years(start_year)
    end_year = Date.today.year
    if start_year == end_year
      "\#{start_year}"
    else
      "\#{start_year}&#8211;\#{end_year}"
    end
  end
  
end