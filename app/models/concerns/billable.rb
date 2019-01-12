# Defines user behavior around paying for the Courier service.
module Billable
  extend ActiveSupport::Concern

  class BillingError < StandardError; end
  class NoSubscription < BillingError; end
  class SubscriptionNotCanceled < BillingError; end

  # Checks if the user currently has a subscription.
  def valid_subscription?
    subscription_expires_at.present? && !subscription_expires_at.past?
  end

  # Subscribes the user to a new plan.
  #
  # Currently assumes that the user doesn't already have a subscription. This
  # needs to be more robust to various situations like that.
  def subscribe(email:, source:)
    create_and_save_customer(email: email, source: source) if source.present?
    create_and_save_subscription
  end

  # Cancels the user's subscription.
  #
  # Does not immediately cancel the subscription. Instead, it marks it to be
  # canceled at the current period end. It will not automatically renew at that
  # time.
  def cancel_subscription
    sub = fetch_subscription
    raise NoSubscription, 'User does not have a subscription' if sub.blank?

    sub.cancel_at_period_end = true
    sub.save

    update! subscription_renews_at: nil
  end

  # Reactives the user's canceled subscription.
  #
  # This will only work if the user is still within the active period of the
  # subscription they canceled.
  def reactivate_subscription
    sub = fetch_subscription
    raise NoSubscription, 'User does not have a subscription' if sub.blank?

    unless sub.cancel_at_period_end
      raise SubscriptionNotCanceled, 'Cannot reactivate subscription ' \
        "because it isn't canceled"
    end

    sub.cancel_at_period_end = false
    sub.save

    update_subscription(sub)
  end

  def update_subscription(subscription = nil)
    subscription ||= fetch_subscription

    period_end = Time.at(subscription.current_period_end).utc
    renews_at = subscription.canceled_at.present? ? nil : period_end
    update!(
      stripe_subscription_id: subscription.id,
      subscription_renews_at: renews_at,
      subscription_expires_at: period_end + 1.day
    )
  end

  private

  def fetch_subscription
    return nil if stripe_subscription_id.blank?

    Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  def create_and_save_customer(email:, source:)
    customer = Stripe::Customer.create(email: email, source: source)
    update!(email: customer.email, stripe_customer_id: customer.id)
    customer
  end

  def create_and_save_subscription
    subscription = Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ plan: Plan::MONTHLY.plan_id }]
    )
    update_subscription(subscription)
    subscription
  end
end
