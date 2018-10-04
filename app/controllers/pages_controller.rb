class PagesController < ApplicationController
  include Elm

  before_action :authenticate_user!

  def index
    tweets = current_user.tweets.to_message
    render_elm :index, tweets: tweets
  end

  def feeds
    feeds = current_user.feed_subscriptions.kept.to_message
    render_elm :feeds, feeds: feeds
  end

  def account
    stripe_key = Rails.configuration.stripe[:publishable_key]
    user = current_user.to_message(stripe: true)
    render_elm :account, stripe_key: stripe_key, user: user
  end
end
