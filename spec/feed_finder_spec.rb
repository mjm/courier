require 'rails_helper'
require 'webmock/rspec'

RSpec.describe FeedFinder do
  let(:html_body) {
    %(<html><head>
      <link rel="alternate" type="application/rss+xml"
            href="https://example.org/feed.xml">
      <link rel="alternate" type="application/json"
            href="https://example.org/feed.json">
      <link rel="alternate" type="application/json"
            href="https://example.org/feed2.json">
      </head><body>Foo!</body></html>)
  }

  let(:feed_body) {
    # Use the www. to test that we actually use the URL in the feed,
    # not just the one we might find in HTML or from user input
    %({ "feed_url": "https://www.example.org/feed.json" })
  }

  let(:rss_body) {
    <<~RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
          <atom:link href="https://example.org/" />
          <atom:link href="https://www.example.org/feed.xml" rel="self" type="application/rss+xml" />
        </channel>
      </rss>
    RSS
  }

  before do
    # Set up a bunch of fake URLs
    stub_request(:get, 'https://example.com/').to_return(
      status: 301,
      headers: { 'Location': 'https://example.org/' }
    )
    stub_request(:get, 'https://example.org/').to_return(
      body: html_body,
      headers: { 'Content-Type': 'text/html' }
    )
    stub_request(:get, 'https://example.org/feed.json').to_return(
      status: 301,
      headers: { 'Location': 'https://www.example.org/feed.json' }
    )
    stub_request(:get, 'https://www.example.org/feed.json').to_return(
      body: feed_body,
      headers: { 'Content-Type': 'application/json' }
    )
    stub_request(:get, 'https://example.org/feed.xml').to_return(
      status: 301,
      headers: { 'Location': 'https://www.example.org/feed.xml' }
    )
    stub_request(:get, 'https://www.example.org/feed.xml').to_return(
      body: rss_body,
      headers: { 'Content-Type': 'application/rss+xml' }
    )
    stub_request(:get, 'https://example.org/foo/').to_return(
      body: '<html><head></head><body></body></html>',
      headers: { 'Content-Type': 'text/html' }
    )
    stub_request(:get, 'https://example.org/bar/').to_return(
      body: 'Foo bar!',
      headers: { 'Content-Type': 'text/plain' }
    )
  end

  def find(url)
    FeedFinder.find(url)
  end

  it 'finds a feed by exact URL' do
    expect(find('https://www.example.org/feed.json'))
      .to eq 'https://www.example.org/feed.json'
  end

  it 'uses the feed URL specified in the feed' do
    expect(find('https://example.org/feed.json'))
      .to eq 'https://www.example.org/feed.json'
  end

  it 'allows leaving off the scheme for HTTPS URLs' do
    expect(find('example.org/feed.json'))
      .to eq 'https://www.example.org/feed.json'
  end

  it 'finds the first JSON feed link on an HTML page' do
    expect(find('example.org'))
      .to eq 'https://www.example.org/feed.json'
  end

  it 'follows redirects' do
    expect(find('example.com'))
      .to eq 'https://www.example.org/feed.json'
  end

  it 'returns nil if there is no feed on the HTML page' do
    expect(find('example.org/foo/')).to be_nil
  end

  it 'returns nil if the content is not HTML or JSON' do
    expect(find('example.org/bar/')).to be_nil
  end

  context 'when there is no JSON feed on the page' do
    let(:html_body) {
      %(<html><head>
        <link rel="alternate" type="application/rss+xml"
              href="https://example.org/feed.xml">
        </head><body>Foo!</body></html>)
    }

    it 'finds the RSS feed' do
      expect(find('example.org'))
        .to eq 'https://www.example.org/feed.xml'
    end
  end
end
