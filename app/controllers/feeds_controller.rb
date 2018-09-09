class FeedsController < ServiceController
  def get_feeds(_req, _env)
    GetFeedsResponse.new(feeds: [])
  end
end
