require File.expand_path("lib/instashow")
require 'rack/test'

ENV['RACK_ENV'] = "test"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.after(:each) do
    Instashow.redis.keys("instashow:test*").each{ |key| Instashow.redis.del key }
  end
end