require 'feed_downloader'

class RefreshFeedWorker
  include Sidekiq::Worker

  attr_reader :feed

  def perform(feed_id)
    @feed = Feed.find(feed_id)
    feed_posts.each do |post|
      import_post post
    end
    update_feed
  end

  private

  def downloaded_feed
    return @downloaded_feed if @downloaded

    @downloaded = true
    @downloaded_feed = feed_downloader.feed
  end

  def feed_downloader
    FeedDownloader.new(feed.url,
                       etag: feed.etag,
                       last_modified: feed.last_modified_at,
                       logger: logger)
  end

  def feed_posts
    []
    # @feed_posts ||= (downloaded_feed&.posts || []).each do |post|
    #   post.feed_id = feed.id
    # end
  end

  def import_post(post)
    feed.feed_subscriptions.each do |subscription|
      import_post_for_subscription post, subscription
    end
  end

  def import_post_for_subscription(post, subscription)
    logger.info "would import post for #{subscription.user.username}"
    # posts_client.import_post(user_id: user_id,
    #                          post: post,
    #                          autopost_delay: autopost_delay(user_id))
  end

  def autopost_delay(subscription)
    subscription.autopost ? 5.minutes : 0
  end

  def update_feed
    feed.refreshed_at = Time.now
    if downloaded_feed
      feed.etag = downloaded_feed.etag
      feed.last_modified_at = downloaded_feed.last_modified
      feed.title = downloaded_feed.title
      feed.home_page_url = downloaded_feed.home_page_url
    end
    feed.save
  end
end
