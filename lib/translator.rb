require 'nokogiri'
require 'tweet_document'

# Transforms a blog post into text that would make sense to tweet.
class Translator
  attr_reader :title, :url, :content_html

  def initialize(title: '', url: '', content_html:)
    @title = title
    @url = url
    @content_html = content_html
  end

  def tweets
    translate
    [@body]
  end

  def media_urls
    translate
    @media_urls
  end

  private

  def translate
    return if @body

    if title.present? && url.present?
      @body = "#{title} #{url}"
      return
    end

    parser.parse(content_html)
    @body = document.contents
    @media_urls = document.media_urls
  end

  def document
    @document ||= TweetDocument.new
  end

  def parser
    @parser ||= Nokogiri::HTML::SAX::Parser.new(document)
  end
end
