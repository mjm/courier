FactoryBot.define do
  factory :user do
    username { 'alice' }
    name { 'Alice' }
    provider { 'twitter' }
    uid { '12345' }
    twitter_access_token { 'qwer' }
    twitter_access_secret { 'asdf' }

    trait :active do
      stripe_customer_id { 'cus_1234' }
      stripe_subscription_id { 'sub_1234' }
      subscription_expires_at { subscription_renews_at + 1.day }
      subscription_renews_at { 4.days.from_now }
    end

    trait :with_feeds do
      transient do
        feeds_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:feed_subscription, evaluator.feeds_count, user: user)
      end
    end

    trait :with_feed do
      after(:create) { |user| create(:feed_subscription, user: user) }
    end
  end
end
