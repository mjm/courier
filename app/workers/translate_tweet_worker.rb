require 'translator'

class TranslateTweetWorker
  include Sidekiq::Worker

  attr_reader :post

  def perform(post_id)
    @post = Post.find(post_id)

    tweets = Translator.new(post.content_html).tweets

    post.feed_subscriptions.each do |subscription|
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

      if subscription.autopost
        logger.info 'Queuing job to post tweets to Twitter'
        PostTweetsWorker.perform_in(autopost_delay, created_tweets.map(&:id))
      end
    end
  end
end
