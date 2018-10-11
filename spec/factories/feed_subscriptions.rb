FactoryBot.define do
  factory :feed_subscription do
    user
    association :feed, :cached

    trait :autopost do
      autopost { true }
    end
  end
end
