module FeedUtils
  # It's important that we normalize URLs because we need to be able to
  # later be able to find the feed that goes with a home page URL.
  def normalize_url(url)
    Addressable::URI.parse(url)&.normalize&.to_s
  end
end
