# This lets us put staging into the dev payment environment
stripe_env = (ENV['STRIPE_ENV'] || Rails.env).to_sym
Rails.configuration.stripe = Rails.application.credentials.stripe[stripe_env]
Stripe.api_key = Rails.configuration.stripe[:secret_key]
