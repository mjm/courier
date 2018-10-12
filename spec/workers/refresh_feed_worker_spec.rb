require 'rails_helper'

RSpec.describe RefreshFeedWorker, type: :worker do
  let(:feed) { create(:feed) }
  let(:downloader) { instance_double('FeedDownloader', feed: downloaded_feed) }
  let(:downloaded_feed) do
    FeedDownloader::Feed.new(
      'Blog Title',
      'https://example.com/',
      '"qwer"',
      'a fake date',
      feed_posts
    )
  end
  let(:feed_posts) { [] }
  before { allow(FeedDownloader).to receive(:new).and_return(downloader) }

  it 'updates the refreshed_at time of the feed' do
    subject.perform(feed.id)
    expect(feed.reload.refreshed_at).not_to be_nil
  end

  it 'downloads posts from the feed URL' do
    subject.perform(feed.id)
    expect(FeedDownloader).to have_received(:new).with(
      feed.url,
      etag: nil,
      last_modified: nil,
      logger: an_instance_of(Logger)
    )
  end

  it 'updates the caching fields for the feed' do
    subject.perform(feed.id)
    feed.reload
    expect(feed.etag).to eq '"qwer"'
    expect(feed.last_modified_at).to eq 'a fake date'
  end

  it 'updates the site info for the feed' do
    subject.perform(feed.id)
    feed.reload
    expect(feed.title).to eq 'Blog Title'
    expect(feed.home_page_url).to eq 'https://example.com/'
  end

  context 'when the feed had failed before' do
    let(:feed) { create(:feed, :failed) }

    it 'sets the feed status to succeeded' do
      feed.failed!
      subject.perform(feed.id)
      expect(feed.reload).to be_succeeded
    end

    it 'clears the refresh message on the feed' do
      feed.update! refresh_message: 'Foo bar'
      subject.perform(feed.id)
      expect(feed.reload.refresh_message).to be_blank
    end
  end

  context 'when the feed has new posts' do
    let(:feed) { create(:feed, :with_posts) }
    let(:existing_post) { feed.posts.first }

    let(:first_post) do
      {
        item_id: existing_post.item_id,
        title: 'Foo',
        content_text: 'bar baz',
        content_html: '',
        published_at: Time.utc(2018, 7, 20, 19, 14, 38),
        modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
      }
    end

    let(:second_post) do
      {
        item_id: 'aslkdjflskd',
        title: '',
        content_text: '',
        content_html: '<p>Florp!</p>',
        published_at: nil,
        modified_at: nil
      }
    end

    let(:feed_posts) { [first_post, second_post] }
    let(:new_post) { feed.posts.where(item_id: 'aslkdjflskd').first }

    it 'creates a new post if the post has not been imported before' do
      expect { subject.perform(feed.id) }.to change { feed.posts.count }.by 1
      expect(new_post).to have_attributes(
        title: '',
        content_html: '<p>Florp!</p>',
        published_at: nil,
        modified_at: nil
      )
    end

    it 'updates an existing post' do
      subject.perform(feed.id)
      expect(existing_post.reload).to have_attributes(
        title: 'Foo',
        content_text: 'bar baz',
        content_html: '',
        published_at: Time.utc(2018, 7, 20, 19, 14, 38),
        modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
      )
    end

    it 'enqueues jobs to translate the posts into tweets' do
      subject.perform(feed.id)

      expect(TranslateTweetWorker).to have_enqueued_sidekiq_job(new_post.id)
      expect(TranslateTweetWorker)
        .to have_enqueued_sidekiq_job(existing_post.id)
    end
  end

  context 'when the feed has been fetched before' do
    let(:feed) { create(:feed, :cached) }

    it 'passes the caching headers to the feed downloader' do
      expect(FeedDownloader).to receive(:new).with(
        feed.url,
        etag: '"abcdef"',
        last_modified: 'Mon Sep 10 19:12:35 CDT 2018',
        logger: an_instance_of(Logger)
      )
      subject.perform(feed.id)
    end
  end

  context 'when the downloaded feed is not modified' do
    let(:feed) { create(:feed, :cached) }
    let(:downloaded_feed) { nil } # FeedDownloader returns nil for 304

    it 'updates the refreshed_at time of the feed' do
      subject.perform(feed.id)
      expect(feed.reload.refreshed_at).not_to be_nil
    end

    it 'does not change the caching fields in the feed' do
      subject.perform(feed.id)
      feed.reload
      expect(feed.etag).to eq '"abcdef"'
      expect(feed.last_modified_at).to eq 'Mon Sep 10 19:12:35 CDT 2018'
    end

    it 'does not change the site information fields in the feed' do
      old_home_page = feed.home_page_url
      subject.perform(feed.id)
      feed.reload
      expect(feed.title).to eq 'Example Web Site'
      expect(feed.home_page_url).to eq old_home_page
    end

    it 'only requests the feed once' do
      expect(downloader).to receive(:feed).once
      subject.perform(feed.id)
    end

    it 'sets the feed status to succeeded' do
      subject.perform(feed.id)
      expect(feed.reload).to be_succeeded
    end
  end

  context 'when the feed cannot be found' do
    before do
      allow(downloader)
        .to receive(:feed)
        .and_raise(
          FeedDownloader::FeedNotFound.new('https://example.com/feed.json')
        )
    end

    it 'sets the feed status to failed' do
      subject.perform(feed.id)
      expect(feed.reload).to be_failed
    end

    it 'sets an appropriate message on the feed' do
      subject.perform(feed.id)
      expect(feed.reload.refresh_message).to eq 'Could not find the feed'
    end
  end

  context 'when the feed downloader raises an error' do
    before do
      allow(downloader).to receive(:feed) { raise 'Foo bar' }
    end

    it 'sets the feed status to failed' do
      subject.perform(feed.id)
      expect(feed.reload).to be_failed
    end

    it 'sets an appropriate message on the feed' do
      subject.perform(feed.id)
      expect(feed.reload.refresh_message).to eq 'An unexpected error occurred'
    end
  end
end
