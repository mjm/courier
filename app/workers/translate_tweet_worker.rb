require 'translator'

class TranslateTweetWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed, log_duplicate_payload: true

  attr_reader :post, :tweets

  def perform(post_id)
    @post = Post.find(post_id)
    @tweets = translated_tweets

    post.feed_subscriptions.kept.each do |subscription|
      existing_tweets = post.tweets.where(feed_subscription: subscription)
      next if existing_tweets.any?

      created_tweets = tweets.map { |tweet| create_tweet(tweet, subscription) }
      subscription.schedule_tweets(created_tweets)
    end
  end

  private

  def translated_tweets
    Translator.new(
      title: post.title,
      url: post.url,
      content_html: post.content_html
    ).tweets
  end

  def create_tweet(tweet, sub)
    logger.info "Creating tweet of post #{post.id} for #{sub.user.username}"
    Tweet.create(
      feed_subscription: sub,
      post: post,
      body: tweet.body,
      media_urls: tweet.media_urls
    )
  end
end
