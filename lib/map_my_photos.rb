require 'bundler'
Bundler.require

module MapMyPhotos
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

  def self.redis
    @redis ||= (
      url = URI(config["REDIS_URL"] || config['REDISTOGO_URL'])

      base_settings = {
        host: url.host,
        port: url.port,
        db: url.path[1..-1],
        password: url.password
      }

      Redis.new(base_settings)
    )
  end
end

require File.expand_path('../map_my_photos/app', __FILE__)
require File.expand_path('../map_my_photos/user', __FILE__)