class StripeController < ApplicationController
  protect_from_forgery except: %i[webhook subscribe]

  def webhook; end

  def subscribe
    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      source: params[:stripeToken]
    )
    current_user.update!(
      email: customer.email,
      stripe_customer_id: customer.id
    )

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{ plan: Plan::MONTHLY.plan_id }]
    )
    current_user.update!(
      stripe_subscription_id: subscription.id,
      subscription_expires_at: Time.at(subscription.current_period_end)
    )

    redirect_to account_url
  end
end
