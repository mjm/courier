class FeedSubscription < ApplicationRecord
  belongs_to :feed
  belongs_to :user
end
