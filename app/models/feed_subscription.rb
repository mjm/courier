class FeedSubscription < ApplicationRecord
  belongs_to :feed
  belongs_to :user

  has_many :tweets

  def autopost_delay
    autopost ? 5.minutes : 0
  end
end
