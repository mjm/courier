require Rails.root / 'app/service/courier_gateway_twirp'

class ApiHandler
  def translate(req, _env)
    forward translator.translate(req)
  end

  def get_user_info(_req, env)
    if env[:user]
      { username: env[:user]['username'],
        name: env[:user]['name'] }
    else
      Twirp::Error.unauthenticated 'You are not logged in'
    end
  end

  def get_posts(_req, env)
    if env[:user]
      forward posts_client(env).get_user_posts(user_id: env[:user]['id'])
    else
      Twirp::Error.unauthenticated 'You are not logged in'
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

  def forward(resp)
    resp.data || resp.error
  end

  def translator
    Courier::TranslatorClient.connect
  end

  def posts_client(env)
    Courier::PostsClient.connect(token: env[:user_token])
  end
end
