class Post < ApplicationRecord
  belongs_to :feed
  delegate :feed_subscriptions, to: :feed

  has_many :tweets
end
