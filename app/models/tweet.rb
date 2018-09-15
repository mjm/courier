class Tweet < ApplicationRecord
  belongs_to :post
  belongs_to :feed_subscription

  delegate :feed, to: :post
  delegate :user, to: :feed_subscription

  enum status: %i[draft canceled posted]
  validate :valid_status_change

  after_create :broadcast

  def post_to_twitter
    PostTweetsWorker.perform_async([id])
  end

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

  def valid_status_change
    if status_was == 'posted' && !posted?
      errors.add(:status, "can't change once posted")
    elsif status_was == 'canceled' && posted?
      errors.add(:status, "can't go from canceled to posted")
    end
  end

  private

  def broadcast
    event = TweetCreatedEvent.new(tweet: to_message)
    EventsChannel.broadcast_event_to(user, event)
  end
end
