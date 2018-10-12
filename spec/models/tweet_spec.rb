require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe '#to_message' do
    let(:message) { subject.to_message }

    context 'when the tweet is a draft' do
      subject { create(:tweet) }

      it 'represents the tweet' do
        expect(message).to eq TweetMessage.new(
          id: subject.id,
          body: 'This is some content.',
          post: subject.post.to_message,
          feed: subject.feed.to_message
        )
      end
    end

    context 'when the tweet is queued' do
      subject { create(:tweet, :queued, will_post_at: Time.utc(2018, 1, 1)) }

      it 'includes the expected post date' do
        expect(message.will_post_at).to eq '2018-01-01T00:00:00Z'
      end
    end

    context 'when the tweet is canceled' do
      subject { create(:tweet, :canceled) }

      it 'includes the correct status' do
        expect(message.status).to eq :CANCELED
      end
    end

    context 'when the tweet is posted' do
      subject { create(:tweet, :posted, posted_at: Time.utc(2018, 1, 1)) }

      it 'includes the correct status' do
        expect(message.status).to eq :POSTED
      end

      it 'includes the ID of the posted tweet' do
        expect(message.posted_tweet_id).to eq '12345'
      end

      it 'includes the timestamp when the tweet was posted' do
        expect(message.posted_at).to eq '2018-01-01T00:00:00Z'
      end
    end
  end

  describe 'changing status' do
    subject { create(:tweet) }

    it 'changes from draft to canceled' do
      subject.canceled!
      expect(subject.reload).to be_canceled
    end

    it 'changes from draft to posted' do
      subject.posted!
      expect(subject.reload).to be_posted
    end

    it 'changes from canceled to draft' do
      subject.canceled!
      subject.draft!
      expect(subject.reload).to be_draft
    end

    it 'does not change from canceled to posted' do
      subject.canceled!
      expect { subject.posted! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_canceled
    end

    it 'does not change from posted to draft' do
      subject.posted!
      expect { subject.draft! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_posted
    end

    it 'does not change from posted to canceled' do
      subject.posted!
      expect { subject.canceled! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_posted
    end
  end

  # rubocop:disable Rails/TimeZone
  describe 'posting tweets to Twitter' do
    let(:the_tweets) { [create(:tweet)] }
    let(:tweet_ids) { the_tweets.map(&:id) }
    before { Timecop.freeze }
    after { Timecop.return }

    it 'enqueues a job to post the tweets' do
      Tweet.post_to_twitter(the_tweets)
      expect(PostTweetsWorker)
        .to have_enqueued_sidekiq_job(tweet_ids).at(Time.now + 2.seconds)
    end

    it 'saves information about the job on the tweets' do
      Tweet.post_to_twitter(the_tweets)
      tweet = the_tweets.first.reload
      expect(tweet.post_job_id).not_to be_nil
      expect(tweet.will_post_at.to_i).to eq 2.seconds.from_now.to_i
    end

    it 'allows overriding the delay before tweeting' do
      Tweet.post_to_twitter(the_tweets, delay: 4.hours)
      tweet = the_tweets.first.reload
      expect(PostTweetsWorker)
        .to have_enqueued_sidekiq_job(tweet_ids).at(Time.now + 4.hours)
      expect(tweet.will_post_at.to_i).to eq 4.hours.from_now.to_i
    end

    context 'when no tweets are passed in' do
      let(:the_tweets) { [] }

      it 'does not enqueue a job' do
        Tweet.post_to_twitter(the_tweets)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job(anything)
      end
    end

    context 'when the user is not currently subscribed' do
      before do
        the_tweets.first.user.update! subscription_expires_at: 1.day.ago
      end

      it 'does not enqueue a job' do
        Tweet.post_to_twitter(the_tweets)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job(anything)
      end
    end
  end
  # rubocop:enable Rails/TimeZone

  describe 'creating a new tweet' do
    let(:post) { create(:post, :subscribed) }
    let(:subscription) { post.feed.feed_subscriptions.reload.first }
    let(:user) { subscription.user }
    subject {
      post.tweets.create(
        feed_subscription: subscription,
        body: 'Foo bar baz'
      )
    }

    it 'broadcasts an event to the user' do
      # We can't check the content of the event because we need the already
      # created tweet in order to know (at the very least) the ID of the tweet.
      # I have not figured out anyway to break this dependency.
      expect { subject }.to broadcast_to("events:#{user.id}")
    end

    it 'does not broadcast to other users' do
      other_user = create(:user)
      expect { subject }.not_to broadcast_to("events:#{other_user.id}")
    end
  end

  describe 'updating a tweet' do
    let(:tweet) { create(:tweet) }
    let(:user) { tweet.user }
    subject { tweet.canceled! }

    it 'broadcasts an event to the user' do
      expect { subject }.to broadcast_to("events:#{user.id}")
    end

    it 'does not broadcast to other users' do
      other_user = create(:user)
      expect { subject }.not_to broadcast_to("events:#{other_user.id}")
    end
  end
end
