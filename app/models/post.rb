class Post < ApplicationRecord
  belongs_to :feed
  delegate :feed_subscriptions, to: :feed

  has_many :tweets, dependent: :destroy

  default_scope -> { order(published_at: :desc) }
  scope :recent, -> { limit(10) }

  def to_message
    PostMessage.new(
      id: id,
      url: url,
      published_at: format_timestamp(published_at),
      modified_at: format_timestamp(modified_at)
    )
  end
end
