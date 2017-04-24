class ServiceResponse

  def initialize(response)
    @response = response
  end

  def value
    @response.body
  end

  def status
    @response.code
  end

end
