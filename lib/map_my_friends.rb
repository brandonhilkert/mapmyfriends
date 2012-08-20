require 'debugger'
require 'bundler'
Bundler.require

module MapMyFriends
  def self.root
    @root ||= Pathname(File.expand_path('../..', __FILE__))
  end

  def self.env
    @env ||= (ENV['RACK_ENV'] || 'development')
  end

  def self.config
    config_file = Pathname.new File.join(root, "config", "local_settings.yml")

    if config_file.file?
      YAML.load(ERB.new(config_file.read).result)[env]
    else
      ENV
    end
  end
end

require File.expand_path('../map_my_friends/app', __FILE__)