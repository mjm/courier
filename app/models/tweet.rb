class Tweet < ApplicationRecord
  belongs_to :post
  belongs_to :feed_subscription

  delegate :feed, to: :post
  delegate :user, to: :feed_subscription

  enum status: %i[draft canceled posted]
end
