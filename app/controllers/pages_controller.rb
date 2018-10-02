class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_json

  def index
    tweets = current_user.tweets.to_message
    @tweets_json = GetTweetsResponse.new(tweets: tweets).to_json
  end

  def feeds
    subscriptions = current_user.feed_subscriptions.kept.to_message
    @feeds_json = GetFeedsResponse.new(feeds: subscriptions).to_json
  end

  def account; end

  private

  def set_user_json
    @user_json = current_user.to_message.to_json
  end
end
