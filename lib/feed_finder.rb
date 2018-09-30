class FeedFinder
  attr_reader :url

  def initialize(url)
    @url = Addressable::URI.heuristic_parse(url, scheme: 'https')
                           .normalize.to_s
  end
  private_class_method :new

  def self.find(url)
    new(url).feed_url
  end

  def feed_url
    attempt_url url
  end

  def attempt_url(url)
    handle_response get_url(url)
  end

  def get_url(url)
    Faraday.new(url) { |conn|
      conn.response :follow_redirects
      conn.adapter :typhoeus
    }.get
  end

  def handle_response(response)
    case response.status
    when 200 then handle_successful_response(response)
    when 404 then nil
    end
  end

  def handle_successful_response(response)
    type = response.headers.fetch(:content_type, '')
    case type
    when %r{^text/html} then handle_html_response(response)
    when %r{^application/json} then handle_feed_response(response)
    else
      Rails.logger.warn "Unexpected content type #{type}"
      nil
    end
  end

  def handle_html_response(response)
    html = Nokogiri::HTML(response.body)
    feeds = html.css('link[rel=alternate][type="application/json"]')
    attempt_url(feeds.first['href']) unless feeds.empty?
  end

  def handle_feed_response(response)
    contents = JSON.parse(response.body)
    contents.fetch('feed_url')
  end
end
