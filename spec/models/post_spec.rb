require 'rails_helper'

RSpec.describe Post, type: :model do
  subject { create(:post, published_at: Time.utc(2018, 1, 1)) }

  describe '#to_message' do
    it 'represents basic metadata about a post' do
      expect(subject.to_message).to eq PostMessage.new(
        id: subject.id,
        url: subject.url,
        published_at: '2018-01-01T00:00:00Z',
        modified_at: '2018-01-01T00:05:00Z'
      )
    end
  end
end
