class StripeController < ApplicationController
  protect_from_forgery except: :webhook

  def webhook; end

  def subscribe
    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      source: params[:stripeToken]
    )
    p customer

    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [{
        plan: 'plan_DcLKc40R2MpDkG'
      }]
    )
    p subscription

    redirect_to account_url
  end
end
