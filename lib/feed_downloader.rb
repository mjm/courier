require 'rss'

class FeedDownloader
  attr_reader :url, :etag, :last_modified, :logger

  def initialize(url,
                 etag: nil,
                 last_modified: nil,
                 logger: Logger.new(File::NULL))
    @url = url
    @etag = etag
    @last_modified = last_modified
    @logger = logger
  end

  def feed
    logger.debug "Downloading feed at #{url}"

    response = connection(url).get { |req|
      req.headers['If-None-Match'] = etag if etag
      req.headers['If-Modified-Since'] = last_modified if last_modified
    }
    handle_response response
  end

  Feed = Struct.new(:title, :home_page_url, :etag, :last_modified, :posts)

  private

  def connection(url)
    Faraday.new(url) do |conn|
      conn.response :follow_redirects
      conn.adapter :typhoeus
    end
  end

  def handle_response(response)
    logger.info "Downloaded #{url} - #{response.status} #{response.body.size}"

    case response.status
    when 200 then parse_feed(response)
    when 304 then nil
    when 404 then raise FeedNotFound, url
    end
  end

  def parse_feed(response)
    type = response.headers.fetch(:content_type, '')
    case type
    when %r{^application/json} then parse_json_feed(response)
    when %r{^application/rss\+xml} then parse_rss_feed(response)
    else
      raise InvalidFormat, type
    end
  end

  def parse_json_feed(response)
    parsed = JSON.parse(response.body)
    Feed.new(parsed.fetch('title'),
             normalize_url(parsed['home_page_url']),
             response.headers['etag'],
             response.headers['last-modified'],
             parse_json_posts(parsed.fetch('items')))
  end

  def parse_rss_feed(response)
    parsed = RSS::Parser.parse(response.body)
    Feed.new(parsed.channel.title,
             normalize_url(parsed.channel.link),
             response.headers['etag'],
             response.headers['last-modified'],
             parse_rss_posts(parsed.items))
  end

  # It's important that we normalize URLs because we need to be able to
  # later be able to find the feed that goes with a home page URL.
  def normalize_url(url)
    Addressable::URI.parse(url)&.normalize&.to_s
  end

  def parse_json_posts(posts)
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

  def parse_rss_posts(posts)
    posts.map { |item|
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

  def parse_timestamp(time)
    Time.iso8601(time) rescue nil
  end

  class FeedNotFound < StandardError
    attr_reader :url

    def initialize(url)
      @url = url
      super "Feed could not be found at URL '#{url}'"
    end
  end

  class InvalidFormat < StandardError
    attr_reader :type

    def initialize(type)
      @type = type
      super "Feed had unexpected content type '#{type}'"
    end
  end
end
