require File.expand_path("lib/map_my_photos")
require 'rack/test'

ENV['RACK_ENV'] = "test"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.after(:each) do
    MapMyPhotos.redis.keys("mapmyphotos:test*").each{ |key| MapMyPhotos.redis.del key }
  end
end