class WebApi

  attr_accessor :req_params, :resp_params

  def initialize(config=GlobalConfig.instance)
    @global_config = config
    @name, @url, @method_name = nil
    @headers = {}
  end

  def init(name, url, &block)
    @name = name
    @url = url if is_valid_url(url)
    instance_eval &block if block
    self
  end

  def url(url_params={})
    host_name = (@global_config.value_for_config("host_url") || "")
    url_suffix = (host_name[-1] == "/" && @url[0] == "/") ? @url[1..-1] : @url
    complete_url = host_name + url_suffix
    complete_url = substitute_values(complete_url, url_params)
    complete_url
  end

  def http_method
    @method_name
  end

  def method(name)
    return unless is_valid_method(name)
    @method_name = name.downcase.to_sym
  end

  def http_headers
    (@global_config.value_for_config("headers") || {}).merge(@headers)
  end

  def headers(headers)
    @headers = headers.inject({}) { |h, (k,v)| h[k.to_sym] = v; h }
  end

  def valid?
    is_valid_method(@method_name) && is_valid_url(@url)
  end

  private

  def is_valid_method(http_method_name)
    !!http_method_name &&
      [:get, :put, :post, :patch, :delete].include?(http_method_name.downcase.to_sym)
  end

  def is_valid_url(url)
    !!url && !(url.strip.empty?)
  end

  def substitute_values(str, value_hash)
    return str if value_hash.empty?
    value_hash = value_hash.inject({}) { |h, (k,v)| h[k.to_sym] = v; h }
    str % value_hash
  end

end
