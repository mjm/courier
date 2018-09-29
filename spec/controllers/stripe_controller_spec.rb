require 'rails_helper'

RSpec.describe StripeController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe '#subscribe' do
    let(:user) { users(:alice) }
    let(:email) { 'foo@example.com' }
    let(:token) { stripe_helper.generate_card_token }
    let(:params) { { stripeEmail: email, stripeToken: token } }

    context 'when a user is signed in' do
      before { sign_in user }

      it 'creates a new subscription for the user' do
        post :subscribe, params: params
        user.reload
        expect(user.stripe_customer_id).to be_present
        expect(user.stripe_subscription_id).to be_present
      end

      it 'redirects to the account page' do
        post :subscribe, params: params
        expect(response).to redirect_to(account_url)
      end
    end
  end
end
