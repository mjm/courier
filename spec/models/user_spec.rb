require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'twitter',
        uid: 'example123',
        info: {
          name: 'Example 123',
          nickname: 'example123'
        },
        credentials: {
          token: 'fake token',
          secret: 'fake secret'
        }
      )
    end
    let(:user) { User.from_omniauth(auth) }

    context 'when the user has not logged in before' do
      it 'creates a new user' do
        expect { user }.to change { User.count }.by 1
      end

      it 'stores relevant information from the auth hash' do
        expect(user).to have_attributes(
          provider: 'twitter',
          uid: 'example123',
          username: 'example123',
          name: 'Example 123',
          twitter_access_token: 'fake token',
          twitter_access_secret: 'fake secret'
        )
      end
    end

    context 'when the user has logged in before' do
      before do
        auth.uid = 'alice123'
      end

      it 'does not create a new user' do
        expect { user }.not_to(change { User.count })
        expect(user).to eq users(:alice)
      end

      it 'updates the information from the auth hash' do
        expect(user.reload).to have_attributes(
          provider: 'twitter',
          uid: 'alice123',
          username: 'example123',
          name: 'Example 123',
          twitter_access_token: 'fake token',
          twitter_access_secret: 'fake secret'
        )
      end
    end

    context 'when the user is not in the allowed user list' do
      before do
        Rails.configuration.allowed_users_filter = ->(u) { u != 'example123' }
      end
      after do
        Rails.configuration.allowed_users_filter = ->(_) { true }
      end

      it 'does not create a new user' do
        expect { user }.not_to(change { User.count })
      end

      it 'returns nil' do
        expect(user).to be_nil
      end
    end
  end
end
