require 'nokogiri'

# Document for parsing a post that is being translated into a tweet
class TweetDocument < Nokogiri::XML::SAX::Document
  attr_reader :contents, :media_urls

  def initialize
    @contents = ''
    @urls = []
    @media_urls = []

    @is_embedded_tweet = false
  end

  def start_element(name, attrs = [])
    case name
    when 'a'
      attrs = Hash[attrs]
      href = attrs['href']
      handle_link_url href if href
    when 'blockquote'
      attrs = Hash[attrs]
      if attrs['class'] == 'twitter-tweet'
        @is_embedded_tweet = true
      else
        contents << '“'
      end
    when 'img'
      attrs = Hash[attrs]
      @media_urls << attrs['src'] if attrs.key? 'src'
    end
  end

  def characters(string)
    return if @is_embedded_tweet
    contents << string.gsub(/\s+/, ' ')
  end

  def end_element(name)
    case name
    when 'p'
      contents << "\n\n"
    when 'br'
      contents << "\n"
    when 'blockquote'
      if @is_embedded_tweet
        @is_embedded_tweet = false
      else
        contents << '”'
      end
    end
  end

  def end_document
    contents.strip!
    contents << " #{@urls.join(' ')}" unless @urls.empty?
    contents.freeze
  end

  private

  def handle_link_url(href)
    if @is_embedded_tweet
      return unless href.starts_with? 'https://twitter.com'
      href = href[/(.*)\?/, 1] # strip ref_src junk
    end
    @urls << href
  end
end
