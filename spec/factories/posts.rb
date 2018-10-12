FactoryBot.define do
  sequence(:item_id) { |n| "post-#{n}" }

  factory :post do
    association :feed, :loaded

    item_id { generate(:item_id) }
    url { "#{feed.home_page_url}#{item_id}" }
    content_html { '<p>This is some content.</p>' }

    published_at { 1.hour.ago }
    modified_at { published_at + 5.minutes }

    trait :subscribed do
      after(:create) do |post|
        create(:feed_subscription, feed: post.feed)
      end
    end

    trait :image do
      content_html {
        '<p>Check this out: <img src="https://example.org/media/foo.jpg"></p>'
      }
    end
  end
end
