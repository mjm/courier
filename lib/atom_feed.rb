require 'rss'

class AtomFeed
  include FeedType

  register 'application/atom+xml', 2

  def parse(response)
    parsed = ::RSS::Parser.parse(response.body)
    FeedDownloader::Feed.new(
      parsed.title.content,
      home_page_url(parsed),
      response.headers['etag'],
      response.headers['last-modified'],
      parse_posts(parsed.entries)
    )
  end

  def find(response)
    feed = Nokogiri::XML(response.body)
    link = feed.xpath('//atom:link[@rel="self"]',
                      'atom' => 'http://www.w3.org/2005/Atom').first
    link.attr('href') if link.present?
  end

  private

  def home_page_url(feed)
    normalize_url(html_url(feed))
  end

  def parse_posts(items)
    items.map { |item|
      {
        item_id: item.id.content,
        title: item.title.content,
        url: html_url(item),
        content_text: content_text(item),
        content_html: content_html(item),
        published_at: item.published&.content,
        modified_at: item.updated&.content
      }
    }
  end

  def html_url(item)
    link = item.links.detect { |l| l.type == 'text/html' && l.rel == 'alternate' }
    if link
      link.href
    else
      ''
    end
  end

  def content_text(item)
    if item.content.type == 'text'
      item.content.content
    else
      ''
    end
  end

  def content_html(item)
    if item.content.type == 'html'
      item.content.content
    else
      ''
    end
  end
end
