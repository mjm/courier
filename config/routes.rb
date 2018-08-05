require Rails.root / 'app/service/courier_gateway_twirp'

Rails.application.routes.draw do
  api_service = Courier::ApiService.new(ApiHandler.new)
  mount api_service, at: api_service.full_name

  get '/auth/twitter/callback', to: 'auth#twitter_callback'

  root to: 'root#index'
end
