require_relative 'lib/database_connection'
require_relative 'lib/user_repository'
require_relative 'lib/peep_repository'
require 'sinatra/base'
require 'sinatra/reloader'

# DatabaseConnection.connect('chitter_database_test')

class Application < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    peep_repo = PeepRepository.new
    @user_repo = UserRepository.new
    @peeps = peep_repo.all.sort do |post|
      DateTime.parse(post.time)
    end
    return erb(:index)
  end

  get "/signup" do
    return erb(:signup)
  end

  post "/new_user" do
    @error = nil
    input_validation
    if @error != nil
      @name = params[:name]
      return erb(:new_user_error)
    else
      repo_users = UserRepository.new
      @user = User.new
      @user.name = params[:name]
      @user.username = params[:username]
      @user.email = params[:email]
      @user.password = params[:password]
      repo_users.create(@user)
      erb(:new_user_confirmation)
    end
  end

  private

  def input_validation
    repo_users = UserRepository.new
    if params[:name].match?(/[^a-z\s-]{2,30}/i)
      @error = "invalid_name"
    elsif (params[:username].match?(/[^a-z\d]/i) || params[:username].length <= 5)
      @error = "invalid_username"
    elsif (!params[:email].include?('@') || params[:email].split("@")[-1] != 'makersacademy.com' || params[:email].split("@")[0].match?(/[^a-z\s-]{2,16}/i))
      @error = "not_makers_email"
    elsif ((params[:name].length == 0) || (params[:username].length == 0) || (params[:password].length == 0))
      @error = "input_missing"
    elsif repo_users.email_exists?(params[:email])
      @error = "email_exists"
    elsif repo_users.username_exists?(@params[:username])
      @username = params[:username]
      @error = "username_taken"
    end  
      @error
  end
end
