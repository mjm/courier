class FeedsController < ServiceController
  def get_feeds(_req, env)
    require_user env do |user|
      GetFeedsResponse.new(feeds: Feed.all.to_message)
    end
  end
end
