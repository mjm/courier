require 'rails_helper'

RSpec.describe Post, type: :model do
  fixtures :posts

  describe '#to_message' do
    it 'represents basic metadata about a post' do
      expect(posts(:example_status).to_message).to eq PostMessage.new(
        id: posts(:example_status).id,
        url: 'https://example.org/abc',
        published_at: '2018-02-02T00:00:00Z',
        modified_at: '2018-02-03T00:00:00Z'
      )
    end
  end
end
