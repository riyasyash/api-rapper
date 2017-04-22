class GlobalConfig

  include Singleton

  attr_accessor :config_map

  def initialize
    self.config_map = {}
  end

  def add_config(key, value)
    self.config_map[key] = value
  end

  def value_for_config(name)
    self.config_map[name]
  end

end
