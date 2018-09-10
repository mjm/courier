require 'nokogiri'
require 'tweet_document'

# Transforms a blog post into text that would make sense to tweet.
class Translator
  attr_reader :input

  def initialize(input)
    @input = input
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
    parser.parse(input)
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
