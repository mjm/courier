class TweetsController < ServiceController
  def get_tweets(_req, env)
    require_user env do |user|
      GetTweetsResponse.new(tweets: user.tweets.to_message)
    end
  end

  def cancel_tweet(req, env)
    require_user env do |user|
      tweet = user.tweets.find(req.id)
      tweet.canceled!
      CancelTweetResponse.new(tweet: tweet.to_message)
    end
  end
end
