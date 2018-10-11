require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe '#to_message' do
    it 'represents a simple feed' do
      feed = create(:feed)
      expect(feed.to_message).to eq FeedMessage.new(
        id: feed.id,
        url: feed.url,
        status: :REFRESHING,
        created_at: feed.created_at.to_s(:iso8601),
        updated_at: feed.updated_at.to_s(:iso8601)
      )
    end

    it 'represents a feed that has been loaded' do
      feed = create(:feed, :loaded,
                    refreshed_at: Time.utc(2018, 1, 1))
      expect(feed.to_message).to eq FeedMessage.new(
        id: feed.id,
        url: feed.url,
        title: 'Example Web Site',
        home_page_url: feed.home_page_url,
        refreshed_at: '2018-01-01T00:00:00Z',
        created_at: feed.created_at.to_s(:iso8601),
        updated_at: feed.updated_at.to_s(:iso8601)
      )
    end

    it 'represents a failed feed' do
      feed = create(:feed, :failed)
      msg = feed.to_message
      expect(msg.status).to eq :FAILED
      expect(msg.refresh_message).to eq 'Could not load feed'
    end
  end

  describe '.register' do
    context 'when the feed has never been registered' do
      let(:user) { create(:user) }
      let(:feed) do
        Feed.register(user, url: 'https://foo.example.org/feed.json')
      end

      it 'creates a new feed' do
        expect { feed }.to change { Feed.count }.by 1
      end

      it 'sets the URL for the feed' do
        expect(feed.url).to eq 'https://foo.example.org/feed.json'
      end

      it 'creates a subscription for the user registering' do
        feed
        expect(user.feed_ids).to include(feed.id)
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

  describe '#refresh' do
    let(:feed) { create(:feed, :loaded) }

    it 'sets the feed status to refreshing' do
      feed.refresh
      expect(feed.reload).to be_refreshing
    end

    it 'enqueues a job to refresh the feed' do
      feed.refresh
      expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
    end
  end
end
