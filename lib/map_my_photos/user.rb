module MapMyPhotos
  class User
    attr_reader :nickname, :access_token

    def initialize(nickname, access_token)
      @nickname, @access_token = nickname, access_token
    end

    def map_url
      "http://mapmyphotosfor.me/#{nickname}"
    end

    def self.find_access_token_by_nickname(nickname)
      if MapMyPhotos.redis.exists(formalize_key(nickname))
        new nickname, MapMyPhotos.redis.hget(formalize_key(nickname), "access_token")
      else
        nil
      end
    end

    def self.create(omniauth)
      MapMyPhotos.redis.hset formalize_key(omniauth["info"]["nickname"]), "access_token", omniauth["credentials"]["token"]
      new omniauth["info"]["nickname"], omniauth["token"]
    end

    def self.formalize_key(key)
      "mapmyphotos:#{MapMyPhotos.env}:#{key}"
    end
  end
end