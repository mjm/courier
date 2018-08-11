class PagesController < ApplicationController
  include ApiClients

  before_action :ensure_logged_in
  before_action :set_user_json

  def index
    @posts_json = Courier::PostList.encode_json(
      posts_client.get_user_posts(user_id: session[:user]['id']).data
    )
  end

  def feeds
  end

  private

  def ensure_logged_in
    redirect_to '/auth/twitter' unless session[:user]
  end

  def set_user_json
    @user_json = {
      username: session[:user]['username'],
      name: session[:user]['name']
    }.to_json
  end
end
