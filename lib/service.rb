require 'rest-client'

class Service

  include Singleton

  attr_accessor :api_call_map

  def initialize
    self.api_call_map = {}
  end

  def add_api(name, call_method)
    self.api_call_map[name] = call_method
  end

  def method_missing(meth, *args, &block)
    web_api = self.api_call_map[meth.to_s]
    if web_api
      puts *args
      self.make_web_call(web_api)
    else
      super
    end
  end

  def make_web_call(web_api)
    RestClient::Request.execute(
      method: web_api.method_name,
      url: web_api.complete_url
    )
  end

end
