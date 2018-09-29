class TweetsController < ServiceController
  def get_tweets(_req, env)
    require_user env do |user|
      GetTweetsResponse.new(tweets: user.tweets.to_message)
    end
  end

  def cancel_tweet(req, env)
    require_tweet env, req.id do |tweet|
      tweet.canceled!
      CancelTweetResponse.new(tweet: tweet.to_message)
    end
  end

  def uncancel_tweet(req, env)
    require_tweet env, req.id do |tweet|
      tweet.draft!
      UncancelTweetResponse.new(tweet: tweet.to_message)
    end
  end

  def update_tweet(req, env)
    require_tweet env, req.id do |tweet|
      tweet.update body: req.body
      tweet.post_to_twitter if req.should_post
      UpdateTweetResponse.new(tweet: tweet.to_message)
    end
  end

  def post_tweet(req, env)
    require_tweet env, req.id do |tweet|
      tweet.post_to_twitter
      PostTweetResponse.new(tweet: tweet.to_message)
    end
  end

  private

  def require_tweet(env, id)
    require_user env do |user|
      tweet = user.tweets.find(id)
      yield tweet
    rescue ActiveRecord::RecordNotFound
      Twirp::Error.not_found "Could not find tweet #{id}"
    end
  end
end
