require 'plan'

# This lets us put staging into the dev payment environment
STRIPE_ENV = (ENV['STRIPE_ENV'] || Rails.env).to_sym
Rails.configuration.stripe = Rails.application.credentials.stripe[STRIPE_ENV]
Stripe.api_key = Rails.configuration.stripe[:secret_key]
StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

Plan::MONTHLY = Plan.new(
  key: :monthly,
  name: 'Monthly Plan',
  plan_id: STRIPE_ENV == :production ? 'plan_DcPlEgFAqBYpnH' : 'plan_DdvIUmVUiibVMa',
  amount: 500,
  interval: 'month'
)

StripeEvent.configure do |events|
  events.subscribe 'invoice.upcoming' do |event|
    invoice = event.data.object
    Rails.logger.info "An invoice is coming soon for customer #{invoice.customer}"
  end

  events.subscribe 'invoice.created' do |event|
    invoice = event.data.object
    Rails.logger.info "Invoice #{invoice.id} was created for customer #{invoice.customer}"
  end

  events.subscribe 'invoice.payment_succeeded' do |event|
    invoice = event.data.object
    Rails.logger.info "Invoice #{invoice.id} for customer #{invoice.customer} was successfully paid"
    subscription = Stripe::Subscription.retrieve(invoice.subscription)
    user = User.where(stripe_subscription_id: subscription.id).first
    if user
      user.update!(subscription_expires_at: Time.at(subscription.current_period_end))
    else
      Rails.logger.error "No user was found for paid subscription #{subscription.id}"
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    invoice = event.data.object
    Rails.logger.info "Invoice #{invoice.id} for customer #{invoice.customer} failed to be paid."
  end
end
