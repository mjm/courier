require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe '#to_message' do
    it 'represents a simple tweet' do
      tweet = tweets(:alice_example_status)
      expect(tweet.to_message).to eq TweetMessage.new(
        id: tweet.id,
        body: 'This is an example status post.',
        post: PostMessage.new(
          id: posts(:example_status).id,
          url: 'https://example.org/abc',
          published_at: '2018-02-02T00:00:00Z',
          modified_at: '2018-02-03T00:00:00Z'
        )
      )
    end
  end

  describe 'changing status' do
    subject { tweets(:alice_example_status) }

    it 'changes from draft to canceled' do
      subject.canceled!
      expect(subject.reload).to be_canceled
    end

    it 'changes from draft to posted' do
      subject.posted!
      expect(subject.reload).to be_posted
    end

    it 'changes from canceled to draft' do
      subject.canceled!
      subject.draft!
      expect(subject.reload).to be_draft
    end

    it 'does not change from canceled to posted' do
      subject.canceled!
      expect { subject.posted! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_canceled
    end

    it 'does not change from posted to draft' do
      subject.posted!
      expect { subject.draft! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_posted
    end

    it 'does not change from posted to canceled' do
      subject.posted!
      expect { subject.canceled! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(subject.reload).to be_posted
    end
  end
end
