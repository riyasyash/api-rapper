class WrapperGenerator

  attr_accessor :global_config, :service

  def initialize
    self.global_config = GlobalConfig.instance
    self.service = Service.instance
  end

  def self.config(&block)
    WrapperGenerator.new.config(&block)
  end

  def config(&block)
		instance_eval(&block) if block
		self
	end

  def endpoint(name, url, &block)
    api = WebApi.new(self.global_config).init(name, url, &block)
    self.service.add_api(name, api)
  end

  def host_url(value=nil, &block)
    host = (block ? block.call() : value)
    self.global_config.add_config("host_url", host)
  end

  def headers(header_hash={})
    self.global_config.add_config("headers", header_hash)
  end

  def header(key, value=nil, &block)
    headers = self.global_config.value_for_config("headers") || {}
    headers[key] = (value || (block && block.call()))
    self.global_config.add_config("headers", headers)
  end

  def dynamic_header(key, &block)
    self.global_config.add_config("dynamic_headers", {}) unless self.global_config.value_for_config("dynamic_headers")
    self.global_config.value_for_config("dynamic_headers")[key] = block
  end

end
