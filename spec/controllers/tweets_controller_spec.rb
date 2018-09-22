require 'rails_helper'

RSpec.describe TweetsController, type: :rpc do
  describe '#get_tweets' do
    rpc_method :GetTweets

    it 'responds with a list of tweets in descending order of publication' do
      expect(response).to eq GetTweetsResponse.new(
        tweets: [
          tweets(:alice_example_post).to_message,
          tweets(:alice_example_status2).to_message,
          tweets(:alice_example_status).to_message
        ]
      )
    end

    include_examples 'an unauthenticated request'
  end

  describe '#cancel_tweet' do
    rpc_method :CancelTweet
    let(:tweet) { tweets(:alice_example_status) }
    let(:request) { { id: tweet.id } }

    it 'moves the tweet to the canceled status' do
      response
      expect(tweet.reload).to be_canceled
    end

    it 'responds with the updated tweet' do
      expect(response.tweet.status).to eq :CANCELED
    end

    include_examples 'an unauthenticated request'

    context 'when the tweet does not exist' do
      let(:request) { { id: 123 } }

      it 'responds with a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end

    context 'when the tweet belongs to someone else' do
      let(:current_user) { users(:bob) }

      it 'responds with a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
  end

  describe '#uncancel_tweet' do
    rpc_method :UncancelTweet
  end

  describe '#update_tweet' do
    rpc_method :UpdateTweet
  end

  describe '#post_tweet' do
    rpc_method :PostTweet
  end
end
