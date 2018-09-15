class PostTweetsWorker
  include Sidekiq::Worker

  attr_reader :tweets

  def perform(tweet_ids)
    @tweets = Tweet.where(id: tweet_ids)
    tweets.each do |tweet|
      next unless tweet.draft?

      posted_tweet = twitter(tweet.user).update(tweet.body)

      tweet.update(
        status: :posted,
        posted_at: Time.now,
        posted_tweet_id: posted_tweet.id.to_s
      )
      broadcast tweet
    end
  end

  private

  def broadcast(tweet)
    event = TweetUpdatedEvent.new(tweet: tweet.to_message)
    EventsChannel.broadcast_event_to(tweet.user, event)
  end

  def twitter(user)
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.credentials.twitter[:api_key]
      config.consumer_secret = Rails.application.credentials.twitter[:api_secret]
      config.access_token = user.twitter_access_token
      config.access_token_secret = user.twitter_access_secret
    end
  end
end