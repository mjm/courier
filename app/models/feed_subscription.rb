class FeedSubscription < ApplicationRecord
  belongs_to :feed
  belongs_to :user

  def autopost_delay
    autopost ? 5.minutes : 0
  end
end
