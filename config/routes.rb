require 'twirp_ext'

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/callbacks' }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Twirp services
  service FeedsController
  service TweetsController
  service UsersController

  # XML-RPC ping service
  mount PingService, at: '/ping'

  # Netlify webhook
  post '/webhook', to: 'hooks#webhook'

  # Stripe
  mount StripeEvent::Engine, at: '/stripe/webhook'
  post '/subscribe', to: 'stripe#subscribe'

  # Elm pages
  get '/feeds', to: 'pages#feeds'
  get '/account', to: 'pages#account', as: :account
  root to: 'pages#index'
end
