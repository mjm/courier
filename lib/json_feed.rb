class JSONFeed
  include FeedType

  register 'application/json', 1

  def parse(response)
    parsed = JSON.parse(response.body)
    FeedDownloader::Feed.new(
      parsed.fetch('title'),
      normalize_url(parsed['home_page_url']),
      response.headers['etag'],
      response.headers['last-modified'],
      parse_posts(parsed.fetch('items'))
    )
  end

  def find(response)
    contents = JSON.parse(response.body)
    contents.fetch('feed_url')
  end

  private

  def parse_posts(posts)
    posts.map do |item|
      {
        item_id: item.fetch('id').to_s,
        title: item.fetch('title', ''),
        url: item.fetch('url', ''),
        content_text: item.fetch('content_text', ''),
        content_html: item.fetch('content_html', ''),
        published_at: parse_timestamp(item.fetch('date_published', '')),
        modified_at: parse_timestamp(item.fetch('date_modified', ''))
      }
    end
  end

  def parse_timestamp(time)
    Time.iso8601(time) rescue nil
  end
end
