class User < ApplicationRecord
  include Billable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :rememberable, :omniauthable, :trackable,
         omniauth_providers: %i[twitter]

  has_many :feed_subscriptions, dependent: :destroy
  has_many :feeds, -> { order(:title, :url) }, through: :feed_subscriptions
  has_many :tweets,
           lambda {
             includes(:post)
               .order('posts.published_at desc', created_at: :desc)
           },
           through: :feed_subscriptions

  class LoginNotAllowed < StandardError; end

  def self.from_omniauth(auth)
    unless allow_username?(auth.info.nickname)
      raise LoginNotAllowed,
            "Twitter user #{auth.info.nickname} is not allowed to login"
    end

    where(provider: auth.provider, uid: auth.uid)
      .first_or_initialize
      .tap { |user| user.apply_omniauth(auth) }
  end

  def self.allow_username?(username)
    Rails.configuration.allowed_users_filter.call(username)
  end

  def apply_omniauth(auth)
    self.username = auth.info.nickname
    self.name = auth.info.name
    self.twitter_access_token = auth.credentials.token
    self.twitter_access_secret = auth.credentials.secret
    save
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
