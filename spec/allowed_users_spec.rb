require 'rails_helper'

RSpec.describe AllowedUsers do
  let(:env) { { 'ALLOWED_TWITTER_USERS' => allowed_users } }
  subject { AllowedUsers.new(env) }

  context 'when the users to allow is not set' do
    let(:env) { {} }

    it 'allows any username' do
      expect(subject.include?('abc')).to be true
      expect(subject.include?('def')).to be true
    end
  end

  context 'when the users to allow is an empty string' do
    let(:allowed_users) { '' }

    it 'allows any username' do
      expect(subject.include?('abc')).to be true
      expect(subject.include?('def')).to be true
    end
  end

  context 'when the users to allow is present' do
    let(:allowed_users) { 'abc,def,ghi' }

    it 'allows the usernames in the list' do
      expect(subject.include?('abc')).to be true
      expect(subject.include?('def')).to be true
      expect(subject.include?('ghi')).to be true
    end

    it 'denies any usernames that are not in the list' do
      expect(subject.include?('123')).to be false
      expect(subject.include?('fleepflorp')).to be false
    end
  end
end
