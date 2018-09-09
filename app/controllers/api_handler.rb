class ApiHandler
  def get_posts(_req, env)
    require_user env do |user|
      forward posts_client(env).get_user_posts(user_id: user['id'])
    end
  end

  def cancel_tweet(req, env)
    require_user env do |_user|
      forward posts_client(env).cancel_tweet(req)
    end
  end

  def update_tweet(req, env)
    require_user env do |_user|
      update_req = { id: req.id, body: req.body }
      response = posts_client(env).update_tweet(update_req)
      return response.error if response.error

      if req.should_post
        forward posts_client(env).submit_tweet(id: req.id)
      else
        response.data
      end
    end
  end

  def submit_tweet(req, env)
    forward posts_client(env).submit_tweet(req)
  end

  def get_feeds(_req, env)
    require_user env do |user|
      forward feeds_client(env).get_user_feeds(user_id: user['id'])
    end
  end

  def register_feed(req, env)
    require_user env do |user|
      req.user_id = user['id']
      forward feeds_client(env).register_feed(req)
    end
  end

  def refresh_feed(req, env)
    require_user env do |_user|
      forward feeds_client(env).refresh_feed(req)
    end
  end

  def update_feed_settings(req, env)
    require_user env do |user|
      req.user_id = user['id']
      forward feeds_client(env).update_feed_settings(req)
    end
  end

  class << self
    def service
      handler = new
      service = Courier::ApiService.new(handler)
      service.before do |rack_env, env|
        env[:session] = rack_env['rack.session']
        env[:user] = env[:session][:user]
        env[:user_token] = user_token(env[:user])
      end
      service
    end

    private

    def user_token(user)
      JWT.encode(
        { sub: user['username'], uid: user['id'] },
        Rails.configuration.x.jwt.secret,
        Rails.configuration.x.jwt.algorithm
      )
    end
  end

  private

  def require_user(env)
    if env[:user]
      yield env[:user]
    else
      Twirp::Error.unauthenticated 'You are not logged in'
    end
  end

  def forward(resp)
    resp.data || resp.error
  end

  def translator
    Courier::TranslatorClient.connect
  end

  def posts_client(env)
    Courier::PostsClient.connect(token: env[:user_token])
  end

  def feeds_client(env)
    Courier::FeedsClient.connect(token: env[:user_token])
  end
end
