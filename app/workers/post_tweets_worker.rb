class PostTweetsWorker
  include Sidekiq::Worker

  attr_reader :tweets

  def perform(tweet_ids)
    @tweets = Tweet.where(id: tweet_ids)
    tweets.each do |tweet|
      next unless tweet.draft?
      next unless tweet.post_job_id == jid

      posted_tweet = twitter(tweet.user).update(tweet.body)

      tweet.update(
        status: :posted,
        posted_at: Time.now,
        posted_tweet_id: posted_tweet.id.to_s
      )
    end
  end

  private

  def twitter(user)
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.credentials.twitter[:api_key]
      config.consumer_secret = Rails.application.credentials.twitter[:api_secret]
      config.access_token = user.twitter_access_token
      config.access_token_secret = user.twitter_access_secret
    end
  end
end
