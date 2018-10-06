require 'rails_helper'

RSpec.describe TweetsController, type: :rpc do
  describe '#get_tweets' do
    rpc_method :GetTweets

    it 'responds with a list of tweets in descending order of publication' do
      expect(response).to eq GetTweetsResponse.new(
        tweets: [
          tweets(:alice_example_post).to_message,
          tweets(:alice_example_multiple2).to_message,
          tweets(:alice_example_multiple1).to_message,
          tweets(:alice_example_status).to_message
        ]
      )
    end

    include_examples 'an unauthenticated request'
  end

  shared_examples 'a request for a missing tweet' do
    context 'when the tweet does not exist' do
      let(:request) { { id: 123 } }

      it 'responds with a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
  end

  shared_examples 'a request from a different user' do
    context 'when the tweet belongs to someone else' do
      let(:current_user) { users(:bob) }

      it 'responds with a not found error' do
        expect(response).to be_a_twirp_error :not_found
      end
    end
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
    include_examples 'a request for a missing tweet'
    include_examples 'a request from a different user'
  end

  describe '#uncancel_tweet' do
    rpc_method :UncancelTweet
    let(:tweet) { tweets(:alice_example_status) }
    let(:request) { { id: tweet.id } }

    before do
      tweet.canceled!
    end

    it 'moves the tweet to the draft status' do
      response
      expect(tweet.reload).to be_draft
    end

    it 'responds with the updated tweet' do
      expect(response.tweet.status).to eq :DRAFT
    end

    include_examples 'an unauthenticated request'
    include_examples 'a request for a missing tweet'
    include_examples 'a request from a different user'
  end

  describe '#update_tweet' do
    rpc_method :UpdateTweet
    let(:tweet) { tweets(:alice_example_status) }
    let(:request) { { id: tweet.id, body: 'Foo bar baz' } }

    it 'updates the body of the tweet' do
      response
      expect(tweet.reload.body).to eq 'Foo bar baz'
    end

    it 'responds with the updated tweet' do
      expect(response.tweet.body).to eq 'Foo bar baz'
      expect(response.tweet.will_post_at).to be_blank
    end

    it 'does not post the tweet by default' do
      response
      expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job(anything)
    end

    context 'when should_post is true' do
      let(:request) { { id: tweet.id, body: 'Foo bar baz', should_post: true } }

      it 'posts the tweet after updating it' do
        response
        expect(PostTweetsWorker).to have_enqueued_sidekiq_job([tweet.id])
      end

      it 'responds with the updated tweet' do
        expect(response.tweet.will_post_at).to be_present
      end
    end

    include_examples 'an unauthenticated request'
    include_examples 'a request for a missing tweet'
    include_examples 'a request from a different user'
  end

  describe '#post_tweet' do
    rpc_method :PostTweet
    let(:tweet) { tweets(:alice_example_status) }
    let(:request) { { id: tweet.id } }

    it 'enqueues a job to post the tweet' do
      response
      expect(PostTweetsWorker).to have_enqueued_sidekiq_job([tweet.id])
    end

    it 'responds with the updated tweet' do
      expect(response.tweet.will_post_at).to be_present
    end

    include_examples 'an unauthenticated request'
    include_examples 'a request for a missing tweet'
    include_examples 'a request from a different user'
  end
end
