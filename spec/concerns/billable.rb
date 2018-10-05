require 'rails_helper'

RSpec.shared_examples_for 'billable' do
  before { Timecop.freeze }
  after { Timecop.return }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:email) { 'foo@example.com' }
  let(:source) { stripe_helper.generate_card_token }
  let(:subscription) {
    Stripe::Subscription.retrieve(subject.stripe_subscription_id)
  }

  describe '#valid_subscription?' do
    it 'is valid if set to expire in the future' do
      subject.subscription_expires_at = 1.month.from_now
      expect(subject).to be_valid_subscription
    end

    it 'is valid if set to expire this instance' do
      subject.subscription_expires_at = Time.current
      expect(subject).to be_valid_subscription
    end

    it 'is invalid if set to expire in the past' do
      subject.subscription_expires_at = 1.minute.ago
      expect(subject).not_to be_valid_subscription
    end

    it 'is invalid if expiration timestamp is missing' do
      subject.subscription_expires_at = nil
      expect(subject).not_to be_valid_subscription
    end
  end

  describe '#subscribe' do
    it 'saves the customer ID from Stripe' do
      subject.subscribe(email: email, source: source)
      expect(subject.stripe_customer_id).to be_present
    end

    it 'saves the subscription ID from Stripe' do
      subject.subscribe(email: email, source: source)
      expect(subject.stripe_subscription_id).to be_present
    end

    it 'subscribes the user to the monthly plan' do
      subject.subscribe(email: email, source: source)
      plan = subscription.items.first.plan
      expect(plan.id).to eq Plan::MONTHLY.plan_id
    end

    it 'subscribes using the right customer' do
      subject.subscribe(email: email, source: source)
      expect(subscription.customer).to eq subject.stripe_customer_id
    end

    it 'saves the expected renewal timestamp' do
      subject.subscribe(email: email, source: source)
      expect(subject.subscription_renews_at.to_i).to eq 1.month.from_now.to_i
    end

    it 'sets the subscription to expire one day after it will renew' do
      subject.subscribe(email: email, source: source)
      expect(subject.subscription_expires_at.to_i)
        .to eq((1.month + 1.day).from_now.to_i)
    end

    context 'when already subscribed' do
    end

    context 'when the subscription has expired' do
    end

    context 'when the payment details are still saved' do
      before do
        subject.subscribe(email: email, source: source)
        @customer = subject.stripe_customer_id
        subject.update!(stripe_subscription_id: nil,
                        subscription_expires_at: nil)
      end

      it 'reuses the existing customer in the new subscription' do
        subject.subscribe(email: '', source: '')
        expect(subject.stripe_customer_id).to eq @customer
      end
    end
  end

  describe '#cancel_subscription' do
    context 'when there is no saved subscription' do
      before { subject.update! stripe_subscription_id: nil }

      it 'raises an error' do
        expect {
          subject.cancel_subscription
        }.to raise_error(Billable::NoSubscription)
      end
    end

    context 'when there is an active subscription' do
      before { subject.subscribe(email: email, source: source) }

      xit 'marks the subscription to be canceled at the end of the period' do
        subject.cancel_subscription
        expect(subscription.cancel_at_period_end).to be true
      end

      it 'clears the renewal timestamp' do
        subject.cancel_subscription
        expect(subject.reload.subscription_renews_at).to be_blank
      end

      it 'leaves the subscription as valid' do
        subject.cancel_subscription
        expect(subject).to be_valid_subscription
      end
    end
  end

  describe '#reactivate_subscription' do
    context 'when there is no saved subscription' do
      before { subject.update! stripe_subscription_id: nil }

      it 'raises an error' do
        expect {
          subject.reactivate_subscription
        }.to raise_error(Billable::NoSubscription)
      end
    end

    # TODO: write tests for this once we can cancel subscriptions
  end
end
