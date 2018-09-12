require 'rails_helper'

RSpec.describe RefreshFeedWorker, type: :worker do
  fixtures :feeds, :posts

  let(:feed) { feeds(:example) }
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
      'https://example.org/feed.json',
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

  context 'when the feed has new posts' do
    let(:first_post) do
      {
        item_id: 'abc',
        title: 'Foo',
        content_text: 'bar baz',
        content_html: '',
        published_at: Time.utc(2018, 7, 20, 19, 14, 38),
        modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
      }
    end

    let(:second_post) do
      {
        item_id: 'def',
        title: '',
        content_text: '',
        content_html: '<p>Florp!</p>',
        published_at: nil,
        modified_at: nil
      }
    end

    let(:feed_posts) { [first_post, second_post] }
    let(:new_post) { feed.posts.where(item_id: 'def').first }

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
      expect(posts(:example_status)).to have_attributes(
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
      expect(TranslateTweetWorker).to have_enqueued_sidekiq_job(posts(:example_status).id)
    end
  end

  context 'when the feed has been fetched before' do
    let(:feed) { feeds(:refreshed_example) }

    it 'passes the caching headers to the feed downloader' do
      expect(FeedDownloader).to receive(:new).with(
        'https://example.com/feed.json',
        etag: '"abcdef"',
        last_modified: 'Mon Sep 10 19:12:35 CDT 2018',
        logger: an_instance_of(Logger)
      )
      subject.perform(feed.id)
    end
  end

  context 'when the downloaded feed is not modified' do
    let(:feed) { feeds(:refreshed_example) }
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
      subject.perform(feed.id)
      feed.reload
      expect(feed.title).to eq 'Example.com'
      expect(feed.home_page_url).to eq 'https://example.com/'
    end

    it 'only requests the feed once' do
      expect(downloader).to receive(:feed).once
      subject.perform(feed.id)
    end
  end
end
