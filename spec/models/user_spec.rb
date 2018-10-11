require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

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
      let(:alice) { create(:user) }
      before do
        auth.uid = alice.uid
      end

      it 'does not create a new user' do
        expect { user }.not_to(change { User.count })
        expect(user).to eq alice
      end

      it 'updates the information from the auth hash' do
        expect(user.reload).to have_attributes(
          provider: 'twitter',
          uid: '12345',
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

  describe '#to_message' do
    context 'when the user does not have a subscription' do
      it 'creates a valid message' do
        expect(subject.to_message).to eq UserMessage.new(
          username: 'alice',
          name: 'Alice'
        )
      end
    end

    context 'when the user has an active subscription' do
      subject {
        create(:user, :active,
               subscription_renews_at: Time.utc(2018, 1, 1))
      }

      it 'creates a valid message' do
        expect(subject.to_message).to eq UserMessage.new(
          username: 'alice',
          name: 'Alice',
          subscribed: true,
          subscription_renews_at: '2018-01-01T00:00:00Z',
          subscription_expires_at: '2018-01-02T00:00:00Z'
        )
      end
    end
  end
end
