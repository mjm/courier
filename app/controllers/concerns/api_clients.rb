module ApiClients
  extend ActiveSupport::Concern

  def user_token
    JWT.encode(
      { sub: current_user['username'], uid: current_user['id'] },
      Rails.configuration.x.jwt.secret,
      Rails.configuration.x.jwt.algorithm
    )
  end

  def posts_client
    Courier::PostsClient.connect(token: user_token)
  end

  def feeds_client
    Courier::FeedsClient.connect(token: user_token)
  end

  private

  def current_user
    session[:user]
  end
end
