class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_json

  def index
    @tweets_json = GetTweetsResponse.encode_json(
      GetTweetsResponse.new(tweets: current_user.tweets.to_message)
    )
  end

  def feeds
    subscriptions = current_user.feed_subscriptions.kept
    @feeds_json = GetFeedsResponse.encode_json(
      GetFeedsResponse.new(feeds: subscriptions.to_message)
    )
  end

  def account; end

  private

  def set_user_json
    @user_json = current_user.to_message.to_json
  end
end
