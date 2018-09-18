require 'rails_helper'
require 'translator'

RSpec.describe Translator do
  let(:title) { '' }
  let(:url) { '' }
  let(:content_html) { '' }
  subject { Translator.new(title: title, url: url, content_html: content_html) }
  let(:translated) { subject.tweets.first }

  matcher :translate_to do |expected|
    match do |actual|
      actual.tweets.first == expected
    end

    failure_message do |actual|
      "expected #{actual.content_html.inspect} to translate to #{expected.inspect},\n but instead translated to #{actual.tweets.first.inspect}"
    end
  end

  context 'when the html is an empty string' do
    it 'translates an empty string' do
      should translate_to ''
    end
  end

  context 'when the html is a simple, unformatted string' do
    let(:content_html) { 'This is a very simple tweet.' }

    it 'translates to the input string' do
      should translate_to content_html
    end

    it 'attaches no media URLs' do
      expect(subject.media_urls).to eq []
    end

    context 'and tweets are requested multiple times' do
      it 'returns the same tweet text' do
        subject.tweets
        should translate_to content_html
      end
    end
  end

  context 'when the html has undesired HTML tags' do
    let(:content_html) do
      %(<p>This is <strong>also</strong> a si<em>mp</em>le tweet.</p>)
    end

    it 'strips the tags' do
      should translate_to 'This is also a simple tweet.'
    end
  end

  context 'when the html has multiple paragraphs' do
    let(:content_html) do
      %(<p>Paragraph 1</p><p>Paragraph 2</p>)
    end

    it 'adds a blank line between the paragraphs' do
      should translate_to %(Paragraph 1\n\nParagraph 2)
    end
  end

  context 'when the html has line break tags' do
    let(:content_html) do
      %(Some content<br>Some more content<br />This is it.)
    end

    it 'converts the tags to line breaks' do
      should translate_to %(Some content\nSome more content\nThis is it.)
    end
  end

  context 'when the html has a link' do
    let(:content_html) do
      %(This is <a href="http://example.com/foo/bar">some #content.</a>)
    end

    it 'appends the URL at the end' do
      should translate_to %(This is some #content. http://example.com/foo/bar)
    end
  end

  context 'when the html has multiple links' do
    let(:content_html) do
      %(
        This is <a href="http://example.com/foo">some</a>
        <a href="http://example.com/bar">#content.</a>
      )
    end

    it 'appends each URL at the end in the order they appear' do
      should translate_to %(This is some #content. http://example.com/foo http://example.com/bar)
    end
  end

  context 'when the html has a block quote' do
    let(:content_html) do
      %(<p>Check this thing out:</p><blockquote>I said a thing</blockquote>)
    end

    it 'wraps the quote in quotation marks' do
      should translate_to %(Check this thing out:\n\n“I said a thing”)
    end
  end

  context 'when the html has HTML entities' do
    let(:content_html) do
      %(<p>I&#8217;m having a &#8220;great time&#8221;. Here's
      &lt;strong&gt;some html&lt;/strong&gt;)
    end

    it 'unescapes the entities' do
      should translate_to "I’m having a “great time”. Here's <strong>some html</strong>"
    end
  end

  context 'when the html has a trailing newline after a paragraph' do
    let(:content_html) do
      "<p>This is some text</p>\n"
    end

    it 'strips the trailing space' do
      should translate_to 'This is some text'
    end
  end

  context 'when the html has image tags in it' do
    let(:content_html) do
      %(<p>Check it out!</p>
        <p><img src="https://example.com/foo.jpg">
           <img src="https://example.com/bar.jpg"></p>)
    end

    it 'translates the body text' do
      should translate_to 'Check it out!'
    end

    it 'attaches the image URLs as a media item' do
      expect(subject.media_urls).to eq %w[
        https://example.com/foo.jpg
        https://example.com/bar.jpg
      ]
    end
  end

  context 'when a title and URL are provided' do
    let(:title) { %(Welcome to Microblogging) }
    let(:url) { %(https://example.com/abc/) }
    let(:content_html) { %(<p>This is my welcome post.</p>) }

    it 'uses the title and URL for the tweet' do
      should translate_to %(Welcome to Microblogging https://example.com/abc/)
    end
  end
end
