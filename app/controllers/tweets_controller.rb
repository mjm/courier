class TweetsController < ServiceController
  def get_tweets(_req, env)
    require_user env do |user|
      GetTweetsResponse.new(tweets: user.tweets.to_message)
    end
  end
end
