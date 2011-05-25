module ViewHelpers
  
  def custom_method
    "Request object: #{h request}"
  end
  
end