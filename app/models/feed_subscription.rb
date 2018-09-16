class FeedSubscription < ApplicationRecord
  include Discard::Model

  belongs_to :feed
  belongs_to :user

  has_many :tweets

  after_create :translate_existing_posts

  def autopost_delay
    autopost ? 5.minutes : 0
  end

  def update_settings(autopost:)
    write_flag :autopost, autopost
    save
  end

  def to_message
    feed.to_message.tap do |m|
      m.settings = FeedSettingsMessage.new(
        autopost: autopost
      )
    end
  end

  def schedule_tweets(tweets)
    Tweet.post_to_twitter(tweets, delay: autopost_delay) if autopost
  end

  private

  def translate_existing_posts
    feed.posts.recent.each do |post|
      TranslateTweetWorker.perform_async(post.id)
    end
  end

  def write_flag(key, value)
    if value == :OFF
      write_attribute key, false
    elsif value == :ON
      write_attribute key, true
    end
  end
end
