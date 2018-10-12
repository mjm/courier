FactoryBot.define do
  factory :feed_subscription do
    association :user, :active
    association :feed, :cached

    trait :autopost do
      autopost { true }
    end
  end
end
