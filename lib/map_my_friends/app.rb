module MapMyFriends
  class App < Sinatra::Base
    set :root, MapMyFriends.root
    enable :sessions

    configure :development do
      register Sinatra::Reloader
    end

    use OmniAuth::Builder do
      provider :facebook, MapMyFriends.config["FACEBOOK_APP_ID"], MapMyFriends.config["FACEBOOK_APP_SECRET"], scope: "user_location,friends_location"
    end

    get '/stylesheets/:name.css' do
     content_type "text/css", charset: "utf-8"
     scss :"stylesheets/#{params[:name]}"
    end

    get '/' do
      erb :index
    end

    get '/auth/facebook/callback' do
      session[:nickname] = request.env["omniauth.auth"].info.nickname
      session[:access_token] = request.env["omniauth.auth"].credentials.token
      session[:created_map] = true
      redirect to("/#{session[:nickname]}")
    end

    get '/:nickname' do
      location = Koala::Facebook::API.new(session[:access_token]).get_object("me")["location"]["name"]
      a = Geokit::Geocoders::YahooGeocoder.geocode location
      @location = a.ll
      erb :show
    end

    def get_checkins(access_token, friend_ids)
      hydra = Typhoeus::Hydra.new
      checkins = []

      friend_ids.each do |friend_id|
        request = Typhoeus::Request.new("https://graph.facebook.com/#{friend_id}/checkins?access_token=#{CGI::escape(access_token)}", method: :get)

        request.on_complete do |response|
          data = JSON::parse(response.body).values.first
          checkins << data unless data.count == 0
        end

        hydra.queue(request)

      end

      hydra.run
    end

  end
end