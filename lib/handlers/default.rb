module Handlers
  class Default

    def initialize(raw_response)
      @raw_response = raw_response
      @success_response, @error_response = nil
      error_occured? ? (@error_response=@raw_response.body) : (@success_response=@raw_response.body)
    end

    def value
      @success_response
    end

    def error_message
      @error_response
    end

    def status
      @raw_response.code
    end

    def error_occured?
      @raw_response.code >= 400
    end

    def raw_response
      @raw_response
    end

  end
end
