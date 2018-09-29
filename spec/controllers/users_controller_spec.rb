require 'rails_helper'

RSpec.describe UsersController, type: :rpc do
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe '#cancel_subscription' do
    rpc_method :CancelSubscription

    context 'when the user has an active subscription' do
      before do
        current_user.subscribe(
          email: 'foo@example.com',
          source: stripe_helper.generate_card_token
        )
        expect(current_user.subscription_renews_at).to be_present
      end

      it 'clears the renewal timestamp for the user' do
        response
        expect(current_user.subscription_renews_at).to be_blank
      end

      it 'responds with the updated user' do
        expect(response.user.subscription_renews_at).to be_blank
      end
    end

    context 'when the user does not have an active subscription' do
      it 'returns an error' do
        expect(response).to be_a_twirp_error(:failed_precondition)
      end
    end
  end

  describe '#reactivate_subscription' do
    rpc_method :ReactivateSubscription

    context 'when the user already has an active subscription' do
      before do
        current_user.subscribe(
          email: 'foo@example.com',
          source: stripe_helper.generate_card_token
        )
      end

      it 'returns an error' do
        expect(response).to be_a_twirp_error(:failed_precondition)
      end
    end

    context 'when the user has never had a subscription' do
      it 'returns an error' do
        expect(response).to be_a_twirp_error(:failed_precondition)
      end
    end

    # StripeMock currently always sets +cancel_at_period_end+ to false
    # when you update a subscription, which isn't what the live API does.
    # For now, we can't have this test.
    xcontext 'when the user has a canceled subscription' do
      before do
        current_user.subscribe(
          email: 'foo@example.com',
          source: stripe_helper.generate_card_token
        )
        current_user.cancel_subscription
      end

      it 'restores the renewal timestamp' do
        response
        expect(current_user.subscription_renews_at).to be_present
      end

      it 'responds with the updated user' do
        expect(response.user.subscription_renews_at).to be_present
      end
    end
  end
end
