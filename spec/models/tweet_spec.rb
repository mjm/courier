require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe '#to_message' do
    it 'represents a simple tweet' do
      tweet = tweets(:alice_example_status)
      expect(tweet.to_message).to eq TweetMessage.new(
        id: tweet.id,
        body: 'This is an example status post.',
        post: PostMessage.new(
          id: posts(:example_status).id,
          url: 'https://example.org/abc',
          published_at: '2018-02-02T00:00:00Z',
          modified_at: '2018-02-03T00:00:00Z'
        ),
        feed: feeds(:example).to_message
      )
    end
  end

  describe 'changing status' do
    subject { tweets(:alice_example_status) }

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
    let(:the_tweets) { [tweets(:alice_example_post)] }
    let(:tweet_ids) { [tweets(:alice_example_post).id] }
    before { Timecop.freeze(2018) }

    it 'enqueues a job to post the tweets' do
      Tweet.post_to_twitter(the_tweets)
      expect(PostTweetsWorker)
        .to have_enqueued_sidekiq_job(tweet_ids).at(Time.now + 2.seconds)
    end

    it 'saves information about the job on the tweets' do
      Tweet.post_to_twitter(the_tweets)
      tweet = the_tweets.first.reload
      expect(tweet.post_job_id).not_to be_nil
      expect(tweet.will_post_at).to eq 2.seconds.from_now
    end

    it 'allows overriding the delay before tweeting' do
      Tweet.post_to_twitter(the_tweets, delay: 4.hours)
      tweet = the_tweets.first.reload
      expect(PostTweetsWorker)
        .to have_enqueued_sidekiq_job(tweet_ids).at(Time.now + 4.hours)
      expect(tweet.will_post_at).to eq 4.hours.from_now
    end

    context 'when no tweets are passed in' do
      let(:the_tweets) { [] }

      it 'does not enqueue a job' do
        Tweet.post_to_twitter(the_tweets)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job(anything)
      end
    end

    context 'when the user is not currently subscribed' do
      before { users(:alice).update! subscription_expires_at: 1.day.ago }

      it 'does not enqueue a job' do
        Tweet.post_to_twitter(the_tweets)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job(anything)
      end
    end
  end
  # rubocop:enable Rails/TimeZone

  describe 'creating a new tweet' do
    let(:post) { posts(:example_untranslated) }
    let(:user) { users(:alice) }
    subject {
      post.tweets.create(
        feed_subscription: feed_subscriptions(:alice_example),
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
      expect { subject }.not_to broadcast_to("events:#{users(:bob).id}")
    end
  end

  describe 'updating a tweet' do
    let(:user) { users(:alice) }
    subject { tweets(:alice_example_status).canceled! }

    it 'broadcasts an event to the user' do
      expect { subject }.to broadcast_to("events:#{user.id}")
    end

    it 'does not broadcast to other users' do
      expect { subject }.not_to broadcast_to("events:#{users(:bob).id}")
    end
  end
end
