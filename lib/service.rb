require 'rest-client'

class Service

  include Singleton

  attr_accessor :api_call_map, :rest_client_req

  def initialize(rest_client_req=RestClient::Request)
    self.api_call_map = {}
    self.rest_client_req = rest_client_req
  end

  def add_api(name, call_method)
    self.api_call_map[name.to_s] = call_method
  end

  def method_missing(meth, *args, &block)
    web_api = self.api_call_map[meth.to_s]
    if web_api
      self.make_web_call(web_api, *args)
    else
      super
    end
  end

  def make_web_call(web_api, *args)
    params_hash = (args[-1] || {})
    request_hash = contruct_request_hash(web_api, params_hash)
    response = self.rest_client_req.execute(request_hash)
    ServiceResponse.new(response)
  end

  private

  def contruct_request_hash(web_api, params_hash)
    url_substitution_hash = (params_hash[:url_params] || {})
    request_hash = {method: web_api.http_method, url: web_api.url(url_substitution_hash)}
    request_hash[:headers] = web_api.http_headers
    request_hash[:payload] = param_hash[:payload] if params_hash[:payload]
    request_hash
  end

end
