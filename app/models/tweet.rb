class Tweet < ApplicationRecord
  belongs_to :post
  belongs_to :feed_subscription

  delegate :feed, to: :post
  delegate :user, to: :feed_subscription

  enum status: %i[draft canceled posted]
  validate :valid_status_change

  after_create :broadcast_create
  after_update :broadcast_update

  def self.post_to_twitter(tweets, delay: 2.seconds)
    tweets = tweets.select { |t| t.user.valid_subscription? }
    return if tweets.empty?

    will_post_at = delay.from_now
    jid = PostTweetsWorker.perform_at(will_post_at, tweets.map(&:id))
    tweets.each do |t|
      t.update! post_job_id: jid, will_post_at: will_post_at
    end
  end

  def post_to_twitter
    self.class.post_to_twitter([self])
  end

  def will_post?
    draft? && post_job_id.present? && will_post_at.present?
  end

  def should_post?(jid:)
    draft? && post_job_id == jid && user.valid_subscription?
  end

  def to_message
    TweetMessage.new(
      id: id,
      body: body,
      post: post.to_message,
      status: status.upcase,
      posted_at: format_timestamp(posted_at),
      posted_tweet_id: posted_tweet_id || '',
      will_post_at: format_timestamp(will_post_at),
      media_urls: media_urls
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

  def broadcast_create
    event = TweetCreatedEvent.new(tweet: to_message)
    EventsChannel.broadcast_event_to(user, event)
  end

  def broadcast_update
    event = TweetUpdatedEvent.new(tweet: to_message)
    EventsChannel.broadcast_event_to(user, event)
  end
end
