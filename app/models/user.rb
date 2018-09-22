class User < ApplicationRecord
  include Billable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :rememberable, :omniauthable, :trackable,
         omniauth_providers: %i[twitter]

  has_many :feed_subscriptions, dependent: :destroy
  has_many :feeds, -> { order(:title, :url) }, through: :feed_subscriptions
  has_many :tweets,
           -> { includes(:post).order('posts.published_at desc') },
           through: :feed_subscriptions

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid)
      .first_or_initialize
      .tap do |user|
        user.username = auth.info.nickname
        user.name = auth.info.name
        user.twitter_access_token = auth.credentials.token
        user.twitter_access_secret = auth.credentials.secret
        user.save
      end
  end

  def register_feed(attrs)
    feed = Feed.register(self, attrs)
    subscription(feed: feed)
  end

  def subscription(feed:)
    feed_subscriptions.find_by(feed: feed)
  end

  def to_message
    UserMessage.new(
      username: username,
      name: name,
      subscribed: stripe_subscription_id.present?,
      subscription_expires_at: format_timestamp(subscription_expires_at),
      subscription_renews_at: format_timestamp(subscription_renews_at)
    )
  end
end
