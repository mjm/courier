require 'rails_helper'

RSpec.describe FeedSubscription, type: :model do
  subject { FeedSubscription.new }

  describe '#autopost_delay' do
    context 'when set to autopost' do
      before { subject.autopost = true }

      it 'is five minutes' do
        expect(subject.autopost_delay).to eq 5.minutes
      end
    end

    context 'when set to not autopost' do
      it 'is zero' do
        expect(subject.autopost_delay).to eq 0
      end
    end
  end
end
