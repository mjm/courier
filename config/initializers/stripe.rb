require 'plan'

# This lets us put staging into the dev payment environment
STRIPE_ENV = (ENV['STRIPE_ENV'] || Rails.env).to_sym
Rails.configuration.stripe = Rails.application.credentials.stripe[STRIPE_ENV]
Stripe.api_key = Rails.configuration.stripe[:secret_key]
StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

monthly_plan_id =
  STRIPE_ENV == :production ? 'plan_DcPlEgFAqBYpnH' : 'plan_DdvIUmVUiibVMa'
Plan::MONTHLY = Plan.new(
  key: :monthly,
  name: 'Monthly Plan',
  plan_id: monthly_plan_id,
  amount: 500,
  interval: 'month'
)

# rubocop:disable Metrics/BlockLength
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
    User.where(stripe_subscription_id: subscription.id).each do |user|
      user.update_subscription(subscription)
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    invoice = event.data.object
    Rails.logger.info "Invoice #{invoice.id} for customer #{invoice.customer} failed to be paid."
  end

  events.subscribe 'customer.subscription.updated' do |event|
    subscription = event.data.object
    Rails.logger.info "Subscription #{subscription.id} was updated."
    User.where(stripe_subscription_id: subscription.id).each do |user|
      user.update_subscription(subscription)
    end
  end

  events.subscribe 'customer.subscription.deleted' do |event|
    subscription = event.data.object
    Rails.logger.info "Subscription #{subscription.id} was deleted."
    User.where(stripe_subscription_id: subscription.id).each do |user|
      user.update(stripe_subscription_id: nil, subscription_expires_at: nil)
    end
  end
end
# rubocop:enable Metrics/BlockLength
