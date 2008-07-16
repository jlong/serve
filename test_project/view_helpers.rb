module ViewHelpers
  def custom_method
    "Request object: #{request.headers['user-agent']}"
  end
end