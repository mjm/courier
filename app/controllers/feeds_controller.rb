class FeedsController < ServiceController
  def get_feeds(_req, env)
    require_user env do |user|
      GetFeedsResponse.new(feeds: user.feed_subscriptions.to_message)
    end
  end

  def register_feed(req, env)
    require_user env do |user|
      feed = user.register_feed(url: req.url)
      subscription = feed.feed_subscriptions.where(user: user).first
      RegisterFeedResponse.new(feed: subscription.to_message)
    end
  end

  def refresh_feed(req, env)
    require_user env do |user|
      user.feeds.find(req.id).refresh
      RefreshFeedResponse.new
    rescue ActiveRecord::RecordNotFound
      Twirp::Error.not_found "Could not find feed #{req.id}"
    end
  end

  def update_feed_settings(req, env)
    require_user env do |user|
      subscription = user.feed_subscriptions.where(feed_id: req.id).first
      subscription.update_settings(autopost: req.autopost)
      UpdateFeedSettingsResponse.new(feed: subscription.to_message)
    end
  end
end
