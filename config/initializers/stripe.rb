# This lets us put staging into the dev payment environment
STRIPE_ENV = (ENV['STRIPE_ENV'] || Rails.env).to_sym
Rails.configuration.stripe = Rails.application.credentials.stripe[stripe_env]
Stripe.api_key = Rails.configuration.stripe[:secret_key]
