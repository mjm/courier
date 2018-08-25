class AuthController < ApplicationController
  def twitter_callback
    user = tweeter.register_user(user_attrs).data
    session[:user] = user
    cookies.encrypted[:user_id] = user.id # for the ActionCable connection
    redirect_to root_url
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_attrs
    {
      username: auth_hash[:info][:nickname],
      name: auth_hash[:info][:name],
      access_token: auth_hash[:credentials][:token],
      access_token_secret: auth_hash[:credentials][:secret]
    }
  end

  def service_token
    Rails.configuration.x.jwt.service_token
  end

  def tweeter
    Courier::TweeterClient.connect(token: service_token)
  end
end
