module MapMyFriends
  class Facebook
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def query
      Koala::Facebook::API.new(access_token).get_connections("me", "locations")
    end

    def locations
      query.map { |item| MapMyFriends::Location.new(item["place"]["location"]["latitude"], item["place"]["location"]["longitude"]) }
    end

  end
end