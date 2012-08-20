require 'sinatra/reloader'

module MapMyFriends
  class App < Sinatra::Base
    set :root, MapMyFriends.root
    enable :sessions

    configure :development do
      register Sinatra::Reloader
    end

    use OmniAuth::Builder do
      provider :facebook, MapMyFriends.config["FACEBOOK_APP_ID"], MapMyFriends.config["FACEBOOK_APP_SECRET"], scope: "user_status,user_photos,user_checkins"
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
      redirect to("/#{session[:nickname]}")
    end

    get '/:nickname' do
      @locations = MapMyFriends::Facebook.new(session[:access_token]).locations
      erb :show
    end

  end
end