module MapMyPhotos
  class App < Sinatra::Base
    set :root, MapMyPhotos.root
    enable :sessions

    configure :development do
      register Sinatra::Reloader
    end

    use OmniAuth::Builder do
      provider :instagram, MapMyPhotos.config["INSTAGRAM_CLIENT_ID"], MapMyPhotos.config["INSTAGRAM_CLIENT_SECRET"]
    end

    get '/stylesheets/:name.css' do
     content_type "text/css", charset: "utf-8"
     scss :"stylesheets/#{params[:name]}"
    end

    get '/' do
      erb :index
    end

    get '/terms' do
      erb :terms
    end

    get '/privacy' do
      erb :privacy
    end

    get '/auth/instagram/callback' do
      user = MapMyPhotos::User.create(request.env["omniauth.auth"])
      session[:created_map] = true
      redirect to("/#{user.nickname}")
    end

    get '/:nickname' do
      @user = MapMyPhotos::User.find_access_token_by_nickname params[:nickname]

      if @user
        Instagram.access_token = @user.access_token
        photos = Instagram.user_recent_media(count: 50)
        puts photos.inspect
        @locations = photos.map{ |photo| [photo["location"], photo["location"]] if photo["location"] }
        puts @locations.each
        erb :show
      else
        @nickname = params[:nickname]
        erb :bummer
      end
    end

  end
end