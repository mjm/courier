class Users::SessionsController < ApplicationController
  def new
    redirect_to user_twitter_omniauth_authorize_path
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
