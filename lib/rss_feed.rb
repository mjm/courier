require 'rss'
require 'feed_utils'

class RSSFeed
  include FeedUtils

  def mime_type
    'application/rss+xml'
  end

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
