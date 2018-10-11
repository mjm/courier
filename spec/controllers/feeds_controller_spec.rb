require 'rails_helper'
require 'webmock/rspec'

RSpec.describe FeedsController, type: :rpc do
  describe '#get_feeds' do
    rpc_method :GetFeeds
    let(:current_user) { create(:user, :with_feeds) }
    before { create(:feed_subscription) }

    it 'returns a list of feeds the user is subscribed to' do
      expect(response.feeds.size).to eq 3
    end

    include_examples 'an unauthenticated request'
  end

  describe '#register_feed' do
    rpc_method :RegisterFeed
    let(:current_user) { create(:user) }
    let(:request) { { url: 'https://foo.example.org/feed.json' } }
    let(:created_feed) {
      Feed.where(url: 'https://foo.example.org/feed.json').first
    }
    let(:created_subscription) { created_feed.feed_subscriptions.first }

    before do
      stub_request(:get, 'https://foo.example.org/feed.json')
        .to_return(
          body: {
            feed_url: 'https://foo.example.org/feed.json'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'registers the feed' do
      expect { response }.to change { current_user.feeds.count }.by 1
    end

    it 'returns a description of the registered feed' do
      response
      expect(response).to eq RegisterFeedResponse.new(
        feed: created_subscription.to_message
      )
    end

    include_examples 'an unauthenticated request'
  end

  describe '#refresh_feed' do
    rpc_method :RefreshFeed
    let!(:user) { create(:user, :with_feed) }
    let(:current_user) { user }
    let(:feed) { user.feeds.first }
    let(:request) { { id: feed.id } }

    it 'enqueues a background job to refresh the feed' do
      response
      expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
    end

    it 'returns an empty response' do
      expect(response).to eq RefreshFeedResponse.new
    end

    include_examples 'an unauthenticated request'

    context 'when the user is not subscribed to the feed' do
      let(:current_user) { create(:user) }
      let(:feed) { user.feeds.first }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end

    context 'when the feed does not exist' do
      let(:request) { { id: 123 } }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
  end

  describe '#update_feed_settings' do
    rpc_method :UpdateFeedSettings
    let!(:user) { create(:user, :with_feed) }
    let(:current_user) { user }
    let(:feed) { user.feeds.first }
    let(:subscription) { user.feed_subscriptions.first }
    let(:request) { { id: feed.id, autopost: :ON } }

    it 'updates the autopost setting' do
      response
      expect(subscription.reload.autopost).to be true
    end

    it 'responds with the updated feed' do
      expect(response.feed.settings.autopost).to be true
    end

    include_examples 'an unauthenticated request'

    context 'when the feed does not exist' do
      let(:request) { { id: 123 } }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end

    context 'when the user is not subscribed to the feed' do
      let(:current_user) { create(:user) }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
  end

  describe '#delete_feed' do
    rpc_method :DeleteFeed
    let!(:user) { create(:user, :with_feed) }
    let(:current_user) { user }
    let(:feed) { user.feeds.first }
    let(:request) { { id: feed.id } }

    it 'discards the feed' do
      expect { response }.to change {
        user.feed_subscriptions.kept.count
      }.by(-1)
    end

    it 'does not delete the feed' do
      response
      expect(user.subscription(feed: feed.id)).to be_present
    end

    it 'returns an empty response' do
      expect(response).to eq DeleteFeedResponse.new
    end

    include_examples 'an unauthenticated request'

    context 'when the feed does not exist' do
      let(:request) { { id: 123 } }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end

    context 'when the user is not subscribed to the feed' do
      let(:current_user) { create(:user) }

      it 'returns a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
  end
end
