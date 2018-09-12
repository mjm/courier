require 'rails_helper'

RSpec.describe FeedsController, type: :rpc do
  fixtures :feeds

  describe '#get_feeds' do
    rpc_method :GetFeeds

    it 'returns a list of feeds the user is subscribed to' do
      expect(response).to eq GetFeedsResponse.new(
        feeds: [feeds(:example).to_message]
      )
    end

    include_examples 'an unauthenticated request'
  end

  describe '#register_feed' do
    rpc_method :RegisterFeed
    let(:request) { { url: 'https://foo.example.org/feed.json' } }
    let(:created_feed) { Feed.where(url: 'https://foo.example.org/feed.json').first }

    it 'registers the feed' do
      expect { response }.to change { users(:alice).feeds.count }.by 1
    end

    it 'returns a description of the registered feed' do
      expect(response).to eq RegisterFeedResponse.new(
        feed: created_feed.to_message
      )
    end

    include_examples 'an unauthenticated request'
  end

  describe '#refresh_feed' do
    rpc_method :RefreshFeed
    let(:feed) { feeds(:example) }
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
      let(:current_user) { users(:bob) }

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
end
