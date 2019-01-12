require 'nokogiri'

# Document for parsing a post that is being translated into a tweet
class TweetDocument < Nokogiri::XML::SAX::Document
  attr_reader :contents, :media_urls

  def initialize
    @contents = ''
    @urls = []
    @media_urls = []

    @is_embedded_tweet = false
    @embedded_tweet_url = nil

    @linked_twitter_user = nil
  end

  def start_element(name, attrs = [])
    method = "start_#{name}"
    send(method, Hash[attrs]) if respond_to?(method, true)
  end

  def characters(string)
    return if @is_embedded_tweet || @linked_twitter_user

    contents << string.gsub(/\s+/, ' ')
  end

  def end_element(name)
    method = "end_#{name}"
    send(method) if respond_to?(method, true)
  end

  def end_document
    contents.strip!
    contents << " #{@urls.join(' ')}" unless @urls.empty?
    contents.freeze
  end

  private

  def start_a(attrs)
    href = attrs['href']
    start_link_url href if href
  end

  TWITTER_USER_REGEX = %r{\Ahttps?://(?:www\.)?twitter\.com/([A-Za-z0-9_]{1,15})/?\z}.freeze

  def start_link_url(href)
    if @is_embedded_tweet
      return unless href.starts_with? 'https://twitter.com'

      @embedded_tweet_url = href[/(.*)\?/, 1] # strip ref_src junk
    elsif TWITTER_USER_REGEX =~ href
      @linked_twitter_user = Regexp.last_match[1]
    else
      @urls << href
    end
  end

  def start_blockquote(attrs)
    if attrs['class'] == 'twitter-tweet'
      @is_embedded_tweet = true
      @embedded_tweet_url = nil
    else
      contents << '“'
    end
  end

  def start_img(attrs)
    @media_urls << attrs['src'] if attrs.key? 'src'
  end

  def end_p
    contents << "\n\n"
  end

  def end_br
    contents << "\n"
  end

  def end_blockquote
    if @is_embedded_tweet
      @urls << @embedded_tweet_url if @embedded_tweet_url
      @is_embedded_tweet = false
    else
      contents << '”'
    end
  end

  def end_a
    return unless @linked_twitter_user

    contents << "@#{@linked_twitter_user}"
    @linked_twitter_user = nil
  end
end
