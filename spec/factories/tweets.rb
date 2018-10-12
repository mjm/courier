FactoryBot.define do
  factory :tweet do
    association :post, :subscribed
    feed_subscription { post.feed.feed_subscriptions.reload.first }

    body { 'This is some content.' }

    trait :queued do
      post_job_id { 'abc' }
      will_post_at { Time.current }
    end

    trait :canceled do
      status { :canceled }
    end

    trait :posted do
      status { :posted }
      posted_tweet_id { '12345' }
      posted_at { 1.second.ago }
    end
  end
end
