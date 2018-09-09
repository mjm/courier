class FeedsController < ServiceController
  def get_feeds(_req, env)
    require_user env do |user|
      GetFeedsResponse.new(feeds: user.feeds.to_message)
    end
  end

  def register_feed(req, env)
    require_user env do |user|
      feed = user.register_feed(url: req.url)
      RegisterFeedResponse.new(feed: feed.to_message)
    end
  end
end
