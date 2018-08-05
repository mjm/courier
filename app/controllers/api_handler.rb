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

  def self.service
    handler = new
    service = Courier::ApiService.new(handler)
    service.before do |rack_env, env|
      env[:session] = rack_env['rack.session']
      env[:user] = env[:session][:user]
    end
    service
  end

  private

  def forward(resp)
    resp.data || resp.error
  end

  def translator
    Courier::TranslatorClient.connect
  end
end
