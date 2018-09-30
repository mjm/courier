require 'feed_finder'

class FeedsController < ServiceController
  def get_feeds(_req, env)
    require_user env do |user|
      GetFeedsResponse.new(feeds: user.feed_subscriptions.kept.to_message)
    end
  end

  def register_feed(req, env)
    require_user env do |user|
      url = FeedFinder.find(req.url)
      subscription = user.register_feed(url: url)
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
    require_subscription env, req.id do |subscription|
      subscription.update_settings(autopost: req.autopost)
      UpdateFeedSettingsResponse.new(feed: subscription.to_message)
    end
  end

  def delete_feed(req, env)
    require_subscription env, req.id do |subscription|
      subscription.discard
      DeleteFeedResponse.new
    end
  end

  private

  def require_subscription(env, id)
    require_user env do |user|
      subscription = user.subscription(feed: id)
      if subscription
        yield subscription
      else
        Twirp::Error.not_found "Could not find feed #{id}"
      end
    end
  end
end
