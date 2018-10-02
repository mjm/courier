class Feed < ApplicationRecord
  has_many :feed_subscriptions, dependent: :restrict_with_error
  has_many :users, through: :feed_subscriptions

  has_many :posts, dependent: :restrict_with_error do
    def import(attrs)
      where(item_id: attrs.fetch(:item_id)).first_or_initialize.tap do |post|
        post.attributes = attrs
        post.save

        TranslateTweetWorker.perform_async(post.id)
      end
    end
  end

  enum status: %i[succeeded failed refreshing]

  scope :by_home_page, lambda { |url|
    normalized_url = Addressable::URI.parse(url).normalize.to_s
    where(home_page_url: normalized_url)
  }

  after_create :refresh
  after_update :broadcast_update

  class << self
    def register(user, url:)
      Feed.where(url: url).first_or_create.tap do |feed|
        user.feeds << feed
      rescue ActiveRecord::RecordNotUnique
        user.subscription(feed: feed).undiscard
      end
    end
  end

  def refresh
    refreshing!
    RefreshFeedWorker.perform_async(id)
  end

  def to_message
    FeedMessage.new(
      id: id,
      url: url,
      title: title,
      home_page_url: home_page_url,
      created_at: format_timestamp(created_at),
      updated_at: format_timestamp(updated_at),
      refreshed_at: format_timestamp(refreshed_at),
      status: status.upcase,
      refresh_message: refresh_message || ''
    )
  end

  private

  def broadcast_update
    feed_subscriptions.each do |subscription|
      event = FeedUpdatedEvent.new(feed: subscription.to_message)
      EventsChannel.broadcast_event_to(subscription.user, event)
    end
  end
end
