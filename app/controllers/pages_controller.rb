class PagesController < ApplicationController
  include ApiClients

  before_action :ensure_logged_in
  before_action :set_user_json

  def index
    @posts_json = Courier::PostList.encode_json(
      posts_client.get_user_posts(user_id: user_id).data
    )
  end

  def feeds
    @feeds_json = Courier::FeedList.encode_json(
      feeds_client.get_user_feeds(user_id: user_id).data
    )
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

  def user_id
    session[:user]['id']
  end
end
