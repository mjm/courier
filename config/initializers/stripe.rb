require 'plan'

# This lets us put staging into the dev payment environment
STRIPE_ENV = (ENV['STRIPE_ENV'] || Rails.env).to_sym
Rails.configuration.stripe = Rails.application.credentials.stripe[stripe_env]
Stripe.api_key = Rails.configuration.stripe[:secret_key]

Plan::MONTHLY = Plan.new(
  key: :monthly,
  name: 'Monthly Plan',
  plan_id: STRIPE_ENV == :production ? 'plan_DcPlEgFAqBYpnH' : 'plan_DcLKc40R2MpDkG',
  amount: 500,
  interval: 'month'
)
