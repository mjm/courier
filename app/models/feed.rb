class Feed < ApplicationRecord
  has_many :feed_subscriptions
  has_many :users, through: :feed_subscriptions

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
