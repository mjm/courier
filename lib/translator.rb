require 'nokogiri'
require 'tweet_document'

# Transforms a blog post into text that would make sense to tweet.
class Translator
  Tweet = Struct.new(:body, :media_urls)

  attr_reader :title, :url, :content_html

  def initialize(title: '', url: '', content_html:)
    @title = title
    @url = url
    @content_html = content_html
  end

  def tweets
    translate
    @tweets
  end

  private

  def translate
    return if @tweets

    if title.present? && url.present?
      translate_with_title
    else
      translate_without_title
    end
  end

  def translate_with_title
    @tweets = [Tweet.new("#{title} #{url}", [])]
  end

  def translate_without_title
    parser.parse(content_html)
    @tweets = [Tweet.new(document.contents, document.media_urls)]
  end

  def document
    @document ||= TweetDocument.new
  end

  def parser
    @parser ||= Nokogiri::HTML::SAX::Parser.new(document)
  end
end
