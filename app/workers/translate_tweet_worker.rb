require 'translator'

class TranslateTweetWorker
  include Sidekiq::Worker

  attr_reader :post

  def perform(post_id)
    @post = Post.find(post_id)

    tweets = Translator.new(
      title: post.title,
      url: post.url,
      content_html: post.content_html
    ).tweets

    post.feed_subscriptions.kept.each do |subscription|
      existing_tweets = post.tweets.where(feed_subscription: subscription)
      next if existing_tweets.any?

      created_tweets = tweets.map do |tweet|
        logger.info "Creating tweet of post #{post.id} for user #{subscription.user.username}"
        Tweet.create(
          feed_subscription: subscription,
          post: post,
          body: tweet
        )
      end

      subscription.schedule_tweets(created_tweets)
    end
  end
end
