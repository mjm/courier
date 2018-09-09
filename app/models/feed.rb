class Feed < ApplicationRecord
  has_many :feed_subscriptions
  has_many :users, through: :feed_subscriptions

  class << self
    def register(user, url:)
      Feed.where(url: url).first_or_create.tap do |feed|
        user.feeds << feed
      rescue ActiveRecord::RecordNotUnique
        # This is fine
      end
    end
  end

  def to_message
    FeedMessage.new(
      id: id,
      url: url,
      title: title,
      home_page_url: home_page_url,
      created_at: created_at.getutc.iso8601,
      updated_at: updated_at.getutc.iso8601,
      refreshed_at: refreshed_at ? refreshed_at.getutc.iso8601 : ''
    )
  end
end
