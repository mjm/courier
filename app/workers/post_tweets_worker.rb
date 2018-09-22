require 'fileutils'
require 'digest'

class PostTweetsWorker
  include Sidekiq::Worker

  attr_reader :tweets

  def perform(tweet_ids)
    @tweets = Tweet.where(id: tweet_ids).all
    tweets
      .select { |tweet| tweet.should_post?(jid: jid) }
      .each do |tweet|
        post_tweet(tweet)
      end
  end

  private

  def post_tweet(tweet)
    media_files = download_media_files(tweet)
    posted_tweet =
      twitter(tweet.user).update_with_media(tweet.body, media_files)

    tweet.update(
      status: :posted,
      posted_at: Time.now.utc,
      posted_tweet_id: posted_tweet.id.to_s
    )
  end

  def twitter(user)
    Twitter::REST::Client.new do |config|
      twitter_credentials = Rails.application.credentials.twitter
      config.consumer_key = twitter_credentials[:api_key]
      config.consumer_secret = twitter_credentials[:api_secret]

      config.access_token = user.twitter_access_token
      config.access_token_secret = user.twitter_access_secret
    end
  end

  def download_media_files(tweet)
    files_dir = create_tweet_directory tweet
    tweet.media_urls.map { |url| download_url(url, files_dir) }
  end

  def create_tweet_directory(tweet)
    files_dir = Rails.root / 'tmp' / jid / 'tweets' / tweet.id.to_s
    FileUtils.rm_rf files_dir
    FileUtils.mkdir_p files_dir
    files_dir
  end

  def download_url(url, dir)
    filename = Digest::SHA1.hexdigest(url)
    path = dir / filename

    response = connection(url).get
    path.binwrite(response.body)
    path.open
  end

  def connection(url)
    Faraday.new(url) do |conn|
      conn.response :follow_redirects
      conn.adapter :typhoeus
    end
  end
end
