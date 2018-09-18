require 'rails_helper'

RSpec.describe TranslateTweetWorker, type: :worker do
  let(:tweet) { post.tweets.first }

  context 'when the tweet has already been translated' do
    let(:post) { posts(:example_status) }

    it 'does not create any new tweets' do
      expect { subject.perform(post.id) }.not_to(change { Tweet.count })
    end

    it 'does not enqueue any jobs to post new tweets' do
      expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job
    end
  end

  context 'when the tweet has not been translated' do
    let(:post) { posts(:example_untranslated) }

    it 'creates a new translated tweet for the post' do
      subject.perform(post.id)
      expect(tweet).to have_attributes(
        body: 'Foo bar baz',
        feed_subscription_id: feed_subscriptions(:alice_example).id,
        post_id: post.id
      )
    end

    context 'when autopost is disabled' do
      it 'does not enqueue any jobs to post new tweets' do
        expect(PostTweetsWorker).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when autopost is enabled' do
      before { feed_subscriptions(:alice_example).update! autopost: true }

      it 'does not enqueue any jobs to post new tweets' do
        subject.perform(post.id)
        expect(PostTweetsWorker).to have_enqueued_sidekiq_job([tweet.id])
      end
    end
  end

  context 'when the tweet has media URLs' do
    let(:post) { posts(:example_images) }

    it 'adds the media URLs to the created tweet' do
      subject.perform(post.id)
      expect(tweet.media_urls).to eq %w[https://example.org/media/foo.jpg]
    end
  end
end
