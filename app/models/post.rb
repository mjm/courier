class Post < ApplicationRecord
  belongs_to :feed
  delegate :feed_subscriptions, to: :feed

  has_many :tweets

  default_scope -> { order(published_at: :desc) }
  scope :recent, -> { limit(10) }

  def to_message
    PostMessage.new(
      id: id,
      url: url,
      published_at: published_at ? published_at.getutc.iso8601 : '',
      modified_at: modified_at ? modified_at.getutc.iso8601 : ''
    )
  end
end
