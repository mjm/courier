class FeedSubscription < ApplicationRecord
  belongs_to :feed
  belongs_to :user

  has_many :tweets

  after_create :translate_existing_posts

  def autopost_delay
    autopost ? 5.minutes : 0
  end

  private

  def translate_existing_posts
    feed.posts.recent.each do |post|
      TranslateTweetWorker.perform_async(post.id)
    end
  end
end
