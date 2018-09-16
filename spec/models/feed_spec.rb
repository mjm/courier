require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#to_message' do
    it 'represents a simple feed' do
      feed = feeds(:example)
      expect(feed.to_message).to eq FeedMessage.new(
        id: feed.id,
        url: 'https://example.org/feed.json',
        title: 'Example.org',
        home_page_url: 'https://example.org/',
        created_at: feed.created_at.to_s(:iso8601),
        updated_at: feed.updated_at.to_s(:iso8601)
      )
    end

    it 'represents a refreshed feed' do
      feed = feeds(:refreshed_example)
      expect(feed.to_message).to eq FeedMessage.new(
        id: feed.id,
        url: 'https://example.com/feed.json',
        title: 'Example.com',
        home_page_url: 'https://example.com/',
        refreshed_at: '2018-01-01T00:00:00Z',
        created_at: feed.created_at.to_s(:iso8601),
        updated_at: feed.updated_at.to_s(:iso8601)
      )
    end
  end

  describe '.register' do
    context 'when the feed has never been registered' do
      let(:feed) do
        Feed.register(users(:alice), url: 'https://foo.example.org/feed.json')
      end

      it 'creates a new feed' do
        expect { feed }.to change { Feed.count }.by 1
      end

      it 'sets the URL for the feed' do
        expect(feed.url).to eq 'https://foo.example.org/feed.json'
      end

      it 'creates a subscription for the user registering' do
        feed
        expect(users(:alice).feed_ids).to include(feed.id)
      end

      it 'enqueues a job to load the contents of the feed' do
        feed
        expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
      end
    end

    context 'when the feed is registered to another user' do
      let(:feed) do
        Feed.register(users(:bob), url: 'https://example.org/feed.json')
      end

      it 'does not create a new feed' do
        expect(feed).to eq feeds(:example)
      end

      it 'creates a subscription for the user registering' do
        feed
        expect(users(:bob).feed_ids).to include(feed.id)
      end
    end
  end
end
