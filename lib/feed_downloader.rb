require 'feed_type'

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
    feed_type = FeedType.by_mime_type(type)

    raise InvalidFormat, type if feed_type.blank?

    feed_type.parse(response)
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
