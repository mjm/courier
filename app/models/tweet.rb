class Tweet < ApplicationRecord
  belongs_to :post
  belongs_to :feed_subscription

  delegate :feed, to: :post
  delegate :user, to: :feed_subscription

  enum status: %i[draft canceled posted]

  def to_message
    TweetMessage.new(
      id: id,
      body: body,
      post: post.to_message,
      status: status.upcase,
      posted_at: posted_at ? posted_at.getutc.iso8601 : '',
      posted_tweet_id: posted_tweet_id || ''
    )
  end
end
