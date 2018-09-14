class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :rememberable, :omniauthable, :trackable,
         omniauth_providers: %i[twitter]

  has_many :feed_subscriptions
  has_many :feeds, -> { order(:title, :url) }, through: :feed_subscriptions
  has_many :tweets, -> { includes(:post).order('posts.published_at desc') }, through: :feed_subscriptions

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.username = auth.info.nickname
      user.name = auth.info.name
      user.twitter_access_token = auth.credentials.token
      user.twitter_access_secret = auth.credentials.secret
      user.save
    end
  end

  def register_feed(attrs)
    Feed.register(self, attrs)
  end
end
