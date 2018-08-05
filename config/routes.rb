Rails.application.routes.draw do
  api_service = ApiHandler.service
  mount api_service, at: api_service.full_name

  get '/auth/twitter/callback', to: 'auth#twitter_callback'

  root to: 'root#index'
end
