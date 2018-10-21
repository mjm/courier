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
      subject.feed rescue nil
      expect(download_request).to have_been_requested
    end

    it 'raises an error' do
      expect { subject.feed }.to raise_error(FeedDownloader::FeedNotFound)
    end
  end

  context 'when the feed is a JSON feed' do
    context 'when the feed can be loaded successfully' do
      context 'and the feed has no items' do
        before do
          download_request.to_return(
            status: 200,
            body: empty_feed_content,
            headers: { content_type: 'application/json' }
          )
        end

        it 'attempts to get the feed' do
          subject.feed
          expect(WebMock).to have_requested(:get, url)
            .with(headers: { 'If-None-Match' => '"asdf"',
                             'If-Modified-Since' => 'fake date' })
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
                                       'Content-Type' => 'application/json',
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
  end

  context 'when the feed is an RSS feed' do
    context 'when the feed can be loaded successfully' do
      context 'and the feed has no items' do
        before do
          download_request.to_return(
            status: 200,
            body: empty_rss_content,
            headers: { content_type: 'application/rss+xml' }
          )
        end

        it 'attempts to get the feed' do
          subject.feed
          expect(WebMock).to have_requested(:get, url)
            .with(headers: { 'If-None-Match' => '"asdf"',
                             'If-Modified-Since' => 'fake date' })
        end

        it 'returns a feed with no posts' do
          expect(subject.feed.posts).to be_empty
        end

        it 'includes some information about the site' do
          expect(subject.feed.title).to eq 'Example Blog'
          expect(subject.feed.home_page_url).to eq 'https://example.com/'
        end
      end

      context 'and the feed has items' do
        before do
          download_request.to_return(status: 200,
                                     body: rss_content,
                                     headers: {
                                       'Content-Type' => 'application/rss+xml',
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
  end

  context 'when the feed is an Atom feed' do
    context 'when the feed can be loaded successfully' do
      context 'and the feed has no items' do
        before do
          download_request.to_return(
            status: 200,
            body: empty_atom_content,
            headers: { content_type: 'application/atom+xml' }
          )
        end

        it 'attempts to get the feed' do
          subject.feed
          expect(WebMock).to have_requested(:get, url)
            .with(headers: { 'If-None-Match' => '"asdf"',
                             'If-Modified-Since' => 'fake date' })
        end

        it 'returns a feed with no posts' do
          expect(subject.feed.posts).to be_empty
        end

        it 'includes some information about the site' do
          expect(subject.feed.title).to eq 'Example Blog'
          expect(subject.feed.home_page_url).to eq 'https://example.com/'
        end
      end

      context 'and the feed has items' do
        before do
          download_request.to_return(status: 200,
                                     body: atom_content,
                                     headers: {
                                       'Content-Type' => 'application/atom+xml',
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
              item_id: 'https://example.com/123',
              title: '',
              url: '',
              content_html: '',
              content_text: 'This is some content.',
              published_at: Time.utc(2018, 7, 20, 19, 14, 38),
              modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
            },
            {
              item_id: 'https://example.com/124',
              title: 'My Fancy Post Title',
              url: 'https://example.com/my-fancy-post-title',
              content_html: '<p>I have some thoughts <em>about things</em>!</p>',
              content_text: '',
              published_at: nil,
              modified_at: Time.utc(2018, 7, 20, 19, 14, 38)
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

  let(:empty_rss_content) do
    <<~RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0"
        xmlns:atom="http://www.w3.org/2005/Atom"
        >
        <channel>
	        <title>Example Blog</title>
          <link>https://example.com</link>
	        <description></description>
        </channel>
      </rss>
    RSS
  end

  let(:rss_content) do
    <<~RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0"
        xmlns:content="http://purl.org/rss/1.0/modules/content/"
        xmlns:atom="http://www.w3.org/2005/Atom"
        >
        <channel>
	        <title>Example Blog</title>
          <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml" />
          <link>https://example.com</link>
	        <description></description>
	        <lastBuildDate>Sat, 13 Oct 2018 10:49:30 +0000</lastBuildDate>
	        <language>en-US</language>
          <item>
		        <title></title>
		        <pubDate>Fri, 20 Jul 2018 19:14:38 +0000</pubDate>
		        <guid isPermaLink="false">123</guid>
            <description><![CDATA[This is some content.]]></description>
          </item>
          <item>
            <title>My Fancy Post Title</title>
		        <link>https://example.com/my-fancy-post-title</link>
		        <guid isPermaLink="false">124</guid>
            <content:encoded><![CDATA[<p>I have some thoughts <em>about things</em>!</p>]]></content:encoded>
          </item>
        </channel>
      </rss>
    RSS
  end

  let(:empty_atom_content) do
    <<~RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <feed
        xmlns="http://www.w3.org/2005/Atom"
        xml:lang="en-US"
        xml:base="https://mattmoriarity.com/wp-atom.php">
      	<title type="text">Example Blog</title>
      	<updated>2018-10-20T02:51:43Z</updated>
        <link rel="alternate" type="text/html" href="https://example.com" />
        <id>https://example.com/feed.atom</id>
        <author>
          <name>John</name>
          <uri>https://john.example.com</uri>
        </author>
      </feed>
    RSS
  end

  let(:atom_content) do
    <<~RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <feed
        xmlns="http://www.w3.org/2005/Atom"
        xml:lang="en-US"
        xml:base="https://mattmoriarity.com/wp-atom.php">
      	<title type="text">Example Blog</title>
      	<updated>2018-10-20T02:51:43Z</updated>
        <link rel="alternate" type="text/html" href="https://example.com" />
        <id>https://example.com/feed.atom</id>
        <entry>
          <title type="html"><![CDATA[]]></title>
          <published>2018-07-20T19:14:38Z</published>
          <updated>2018-07-20T19:14:38Z</updated>
          <id>https://example.com/123</id>
          <content type="text"><![CDATA[This is some content.]]></content>
          <author>
            <name>John</name>
            <uri>https://john.example.com</uri>
          </author>
        </entry>
        <entry>
          <title type="text">My Fancy Post Title</title>
          <updated>2018-07-20T19:14:38Z</updated>
          <link rel="alternate" type="text/html" href="https://example.com/my-fancy-post-title" />
          <id>https://example.com/124</id>
          <content type="html"><![CDATA[<p>I have some thoughts <em>about things</em>!</p>]]></content>
          <author>
            <name>John</name>
            <uri>https://john.example.com</uri>
          </author>
        </entry>
      </feed>
    RSS
  end
end
