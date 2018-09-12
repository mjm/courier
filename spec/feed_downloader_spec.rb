require 'rails_helper'

require 'feed_downloader'
require 'webmock/rspec'

RSpec.describe FeedDownloader do
  let(:url) { 'https://example.com/feed.json' }
  let(:download_request) { stub_request(:get, url) }

  subject do
    FeedDownloader.new(url, etag: '"asdf"', last_modified: 'fake date')
  end

  context 'when the feed is not found' do
    before { download_request.to_return(status: 404) }

    it 'attempts to get the feed' do
      subject.feed rescue nil # rubocop:disable Style/RescueModifier
      expect(download_request).to have_been_requested
    end

    it 'raises an error' do
      expect { subject.feed }.to raise_error(FeedDownloader::NotFoundError)
    end
  end

  context 'when the feed can be loaded successfully' do
    context 'and the feed has no items' do
      before do
        download_request.to_return(status: 200, body: empty_feed_content)
      end

      it 'attempts to get the feed' do
        subject.feed
        expect(WebMock).to have_requested(:get, url).with(headers: {
          'If-None-Match' => '"asdf"',
          'If-Modified-Since' => 'fake date'
        })
      end

      it 'returns a feed with no posts' do
        expect(subject.feed.posts).to be_empty
      end

      it 'includes some information about the site' do
        expect(subject.feed.title).to eq 'Example Blog'
        expect(subject.feed.home_page_url).to be_nil
      end
    end

    context 'and the feed has items' do
      before do
        download_request.to_return(status: 200,
                                   body: feed_content,
                                   headers: {
                                     'Etag' => '"asdf"',
                                     'Last-Modified' => 'fake date'
                                   })
      end

      it 'attempts to get the feed' do
        subject.feed
        expect(download_request).to have_been_requested
      end

      it 'returns a feed with posts' do
        expect(subject.feed.posts).to eq [
          {
            item_id: '123',
            title: '',
            url: '',
            content_html: '',
            content_text: 'This is some content.',
            published_at: Time.utc(2018, 7, 20, 19, 14, 38),
            modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
          },
          {
            item_id: '124',
            title: 'My Fancy Post Title',
            url: 'https://example.com/my-fancy-post-title',
            content_html: '<p>I have some thoughts <em>about things</em>!</p>',
            content_text: '',
            published_at: nil,
            modified_at: nil
          }
        ]
      end

      it 'includes the caching headers in the feed' do
        expect(subject.feed.etag).to eq '"asdf"'
        expect(subject.feed.last_modified).to eq 'fake date'
      end

      it 'includes information about the site' do
        expect(subject.feed.title).to eq 'Example Blog'
        expect(subject.feed.home_page_url).to eq 'https://example.com/'
      end
    end
  end

  context 'when the feed content is cached' do
    before do
      download_request.to_return(status: 304)
    end

    it 'returns a nil feed' do
      expect(subject.feed).to be_nil
    end
  end

  let(:empty_feed_content) do
    {
      title: 'Example Blog',
      feed_url: 'https://example.com/feed.json',
      items: []
    }.to_json
  end

  let(:feed_content) do
    {
      title: 'Example Blog',
      feed_url: 'https://example.com/feed.json',
      home_page_url: 'https://example.com',
      items: [
        {
          id: '123',
          content_text: 'This is some content.',
          date_published: '2018-07-20T19:14:38+00:00',
          date_modified: '2018-07-20T19:14:38+00:00'
        },
        {
          id: 124,
          title: 'My Fancy Post Title',
          content_html: '<p>I have some thoughts <em>about things</em>!</p>',
          url: 'https://example.com/my-fancy-post-title'
        }
      ]
    }.to_json
  end
end
