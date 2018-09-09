class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_json

  def index
    @posts_json = { posts: [] }.to_json
  end

  def feeds
    @feeds_json = { feeds: [] }.to_json
  end

  private

  def set_user_json
    @user_json = {
      username: current_user.username,
      name: current_user.name
    }.to_json
  end
end
