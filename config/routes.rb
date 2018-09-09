Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'auth' }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Twirp services
  mount FeedsController.service, at: FeedsController.path

  # XML-RPC ping service
  mount PingService, at: '/ping'

  # Elm pages
  get '/feeds', to: 'pages#feeds'
  root to: 'pages#index'
end
