Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'auth' }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  api_service = ApiHandler.service
  mount api_service, at: api_service.full_name

  mount PingService, at: '/ping'

  get '/feeds', to: 'pages#feeds'
  root to: 'pages#index'
end
