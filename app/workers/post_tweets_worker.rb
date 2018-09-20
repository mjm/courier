require 'fileutils'
require 'digest'

class PostTweetsWorker
  include Sidekiq::Worker

  attr_reader :tweets

  def perform(tweet_ids)
    @tweets = Tweet.where(id: tweet_ids)
    tweets.each do |tweet|
      next unless tweet.draft?
      next unless tweet.post_job_id == jid
      next unless tweet.user.valid_subscription?

      media_files = download_media_files(tweet)
      posted_tweet = twitter(tweet.user).update_with_media(tweet.body, media_files)

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

  def download_media_files(tweet)
    files_dir = Rails.root / 'tmp' / jid / 'tweets' / tweet.id.to_s
    FileUtils.rm_rf files_dir
    FileUtils.mkdir_p files_dir
    tweet.media_urls.map do |url|
      filename = Digest::SHA1.hexdigest(url)
      path = files_dir / filename

      response = connection(url).get
      path.binwrite(response.body)
      path.open
    end
  end

  def connection(url)
    Faraday.new(url) do |conn|
      conn.response :follow_redirects
      conn.adapter :typhoeus
    end
  end
end
