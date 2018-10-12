require 'rails_helper'

RSpec.describe TranslateTweetWorker, type: :worker do
  let(:tweet) { post.tweets.first }

  context 'when the tweet has already been translated' do
    let!(:tweet) { create(:tweet) }
    let(:post) { tweet.post }

    it 'does not create any new tweets' do
      expect { subject.perform(post.id) }.not_to(change { Tweet.count })
    end

    it 'does not enqueue any jobs to post new tweets' do
      expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the tweet has not been translated' do
    let(:post) { create(:post, :subscribed) }
    let(:subscription) { post.feed.feed_subscriptions.reload.first }

    it 'creates a new translated tweet for the post' do
      subject.perform(post.id)
      expect(tweet).to have_attributes(
        body: 'This is some content.',
        feed_subscription_id: subscription.id,
        post_id: post.id
      )
    end

    context 'when autopost is disabled' do
      it 'does not enqueue any jobs to post new tweets' do
        subject.perform(post.id)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when autopost is enabled' do
      before { subscription.update! autopost: true }

      it 'does not enqueue any jobs to post new tweets' do
        subject.perform(post.id)
        expect(PostTweetsWorker).to have_enqueued_sidekiq_job([tweet.id])
      end
    end
  end

  context 'when the post has been updated since being translated originally' do
    let!(:tweet) { create(:tweet, body: 'This is some old content.') }
    let(:post) { tweet.post }
    before { tweet.feed_subscription.update! autopost: true }

    context 'and the tweet is still a draft' do
      it 'does not create any new tweets' do
        expect { subject.perform(post.id) }.not_to(change { Tweet.count })
      end

      it 'updates the body of the tweet with the new translation' do
        subject.perform(post.id)
        expect(tweet.reload.body).to eq 'This is some content.'
      end

      it 'enqueues a new job to post the tweet' do
        subject.perform(post.id)
        expect(PostTweetsWorker).to have_enqueued_sidekiq_job([tweet.id])
      end
    end

    context 'and the tweet has already been posted' do
      before { tweet.posted! }

      it 'does not create any new tweets' do
        expect { subject.perform(post.id) }.not_to(change { Tweet.count })
      end

      it 'does not update the body of the tweet with the new translation' do
        subject.perform(post.id)
        expect(tweet.reload.body).not_to eq 'This was a triumph!'
      end

      it 'does not enqueue any jobs to post new tweets' do
        subject.perform(post.id)
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job
      end
    end
  end

  context 'when the tweet has media URLs' do
    let(:post) { create(:post, :subscribed, :image) }

    it 'adds the media URLs to the created tweet' do
      subject.perform(post.id)
      expect(tweet.media_urls).to eq %w[https://example.org/media/foo.jpg]
    end
  end
end
