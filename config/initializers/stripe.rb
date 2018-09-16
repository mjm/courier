Rails.configuration.stripe = Rails.application.credentials.stripe[Rails.env.to_sym]
Stripe.api_key = Rails.configuration.stripe[:secret_key]
