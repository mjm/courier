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
    Rails.configuration.allowed_users.include?(username)
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

  def to_message(stripe: false)
    msg = UserMessage.new(
      username: username,
      name: name,
      subscribed: stripe_subscription_id.present?,
      subscription_expires_at: format_timestamp(subscription_expires_at),
      subscription_renews_at: format_timestamp(subscription_renews_at)
    )
    add_card_details(msg) if stripe
    msg
  end

  private

  def add_card_details(msg)
    source = fetch_payment_source
    msg.card = card_message(source) if source.present?
  end

  def fetch_payment_source
    return nil if stripe_customer_id.blank?

    customer = Stripe::Customer.retrieve(stripe_customer_id)
    return nil if customer.default_source.blank?

    customer.sources.detect { |s| s.id == customer.default_source }
  end

  def card_message(source)
    CardMessage.new(
      brand: source.brand,
      last_four: source.last4,
      exp_month: source.exp_month,
      exp_year: source.exp_year
    )
  end
end
