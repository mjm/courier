FactoryBot.define do
  sequence(:url) { |n| "https://example#{n}.com/" }

  factory :feed do
    url { "#{generate(:url)}feed.json" }
    status { 'refreshing' }

    trait :loaded do
      home_page_url { generate(:url) }
      url { "#{home_page_url}feed.json" }
      title { 'Example Web Site' }
      refreshed_at { 1.hour.ago }
      status { 'succeeded' }

      # Creating a feed automatically marks it as refreshing,
      # as it triggers a refresh of the feed.
      after(:create) do |feed|
        feed.update! status: :succeeded
      end
    end

    trait :cached do
      loaded
      etag { '"abcdef"' }
      last_modified_at { 'Mon Sep 10 19:12:35 CDT 2018' }
    end

    trait :failed do
      status { 'failed' }
      refresh_message { 'Could not load feed' }

      after(:create) do |feed|
        feed.update! status: :failed
      end
    end

    trait :with_posts do
      transient do
        posts_count { 3 }
      end

      after(:create) do |feed, evaluator|
        create_list(:post, evaluator.posts_count, feed: feed)
      end
    end
  end
end
