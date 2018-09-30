require 'rails_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'billable'

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
      let(:allowed_users) {
        AllowedUsers.new('ALLOWED_TWITTER_USERS' => 'abc,def')
      }
      before { Rails.configuration.allowed_users = allowed_users }
      after { Rails.configuration.allowed_users = AllowedUsers.new }

      it 'does not create a new user' do
        expect { user rescue nil }.not_to(change { User.count })
      end

      it 'raises an error' do
        expect { user }.to raise_error(User::LoginNotAllowed)
      end
    end
  end
end
