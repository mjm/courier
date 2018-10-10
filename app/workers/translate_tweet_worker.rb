require 'translator'
require 'tweet_splitter'

class TranslateTweetWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed, log_duplicate_payload: true

  attr_reader :post, :tweets

  def perform(post_id)
    @post = Post.find(post_id)
    @tweets = translated_tweets

    post.feed_subscriptions.kept.each do |subscription|
      existing_tweets = existing_tweets_for(subscription)
      create_or_update_tweets(subscription,
                              tweets,
                              existing_tweets)
    end
  end

  private

  def translated_tweets
    tweet = Translator.translate(
      title: post.title,
      url: post.url,
      content_html: post.content_html
    )
    first, *rest = TweetSplitter.split(tweet.body)

    # For now, just put all media on the first tweet
    first_tweet = Translator::Tweet.new(first, tweet.media_urls)
    [first_tweet] + rest.map { |t| Translator::Tweet.new(t, []) }
  end

  def existing_tweets_for(subscription)
    post.tweets.where(feed_subscription: subscription).order(:id)
  end

  def create_or_update_tweets(subscription, tweets, existing_tweets)
    created_tweets = tweets.zip(existing_tweets).map { |tweet, existing_tweet|
      if existing_tweet.present?
        update_tweet(existing_tweet, tweet) unless existing_tweet.posted?
      else
        create_tweet(tweet, subscription)
      end
    }.compact

    subscription.schedule_tweets(created_tweets)
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

  def update_tweet(existing_tweet, tweet)
    logger.info "Updating tweet #{existing_tweet.id}"
    existing_tweet.update! body: tweet.body, media_urls: tweet.media_urls
    existing_tweet
  end
end
