class TweetSplitter
  include Twitter::TwitterText::Validation

  def initialize(text)
    @text = text
  end
  private_class_method :new

  def self.split(text)
    new(text).split
  end

  def split
    number_tweets(split_text(@text, []))
  end

  private

  def split_text(text, tweets)
    str = shorten_text(text)
    tweets << str

    str = text[str.length..-1].strip
    if str.present?
      split_text(str, tweets)
    else
      tweets
    end
  end

  def shorten_text(str)
    results = parse_tweet(str)
    unless results[:valid]
      str = drop_word(truncate(str, results))
      while (results = parse_tweet(str + ' (XX/XX)')) && !results[:valid]
        str = drop_word(str)
      end
    end
    str
  end

  def truncate(str, results)
    s = results[:valid_range_start]
    e = results[:valid_range_end]

    str[s..e]
  end

  def drop_word(str)
    str.sub(/\s+\S*\Z/, '')
  end

  def number_tweets(tweets)
    return tweets if tweets.size == 1

    total = tweets.size
    tweets.each_with_index.map { |t, i| "#{t} (#{i + 1}/#{total})" }
  end
end
