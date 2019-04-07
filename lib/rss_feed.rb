require 'rss'

class RSSFeed
  include FeedType

  register 'application/rss+xml', 3, %w[application/xml]

  def parse(response)
    parsed = ::RSS::Parser.parse(response.body)
    FeedDownloader::Feed.new(
      parsed.channel.title,
      normalize_url(parsed.channel.link),
      response.headers['etag'],
      response.headers['last-modified'],
      parse_posts(parsed.items)
    )
  end

  def find(response)
    feed = Nokogiri::XML(response.body)
    link = feed.xpath('//atom:link[@rel="self"]',
                      'atom' => 'http://www.w3.org/2005/Atom').first
    link.attr('href') if link.present?
  end

  private

  def parse_posts(items)
    items.map { |item|
      {
        item_id: item.guid.content,
        title: item.title || '',
        url: item.link || '',
        content_text: item.description || '',
        content_html: item.content_encoded || '',
        published_at: item.pubDate,
        modified_at: item.pubDate
      }
    }
  end
end
