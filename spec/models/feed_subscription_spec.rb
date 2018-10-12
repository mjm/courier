require 'rails_helper'

RSpec.describe FeedSubscription, type: :model do
  subject { create(:feed_subscription) }

  describe '#autopost_delay' do
    context 'when set to autopost' do
      subject { create(:feed_subscription, :autopost) }

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

  describe 'updating settings' do
    context 'autopost' do
      it 'does not change the setting when :UNCHANGED' do
        expect(subject.autopost).to be false
        subject.update_settings(autopost: :UNCHANGED)
        expect(subject.reload.autopost).to be false
        subject.update! autopost: true
        subject.update_settings(autopost: :UNCHANGED)
        expect(subject.reload.autopost).to be true
      end

      it 'enables the setting when :ON' do
        expect(subject.autopost).to be false
        subject.update_settings(autopost: :ON)
        expect(subject.reload.autopost).to be true
      end

      it 'disables the setting when :OFF' do
        subject.update! autopost: true
        subject.update_settings(autopost: :OFF)
        expect(subject.reload.autopost).to be false
      end
    end
  end

  describe '#to_message' do
    subject {
      create(:feed_subscription, :autopost,
             feed: create(:feed, :cached,
                          refreshed_at: Time.utc(2018, 1, 1)))
    }
    let(:feed) { subject.feed }

    it 'represents a feed with settings included' do
      expect(subject.to_message).to eq FeedMessage.new(
        id: feed.id,
        url: feed.url,
        title: 'Example Web Site',
        home_page_url: feed.home_page_url,
        refreshed_at: '2018-01-01T00:00:00Z',
        created_at: feed.created_at.to_s(:iso8601),
        updated_at: feed.updated_at.to_s(:iso8601),
        settings: FeedSettingsMessage.new(
          autopost: true
        )
      )
    end
  end

  describe 'creating a new subscription' do
    let(:feed) { create(:feed, :with_posts) }
    let(:user) { create(:user) }

    it 'enqueues a job to translate existing posts for the new user' do
      user.feeds << feed
      expect(TranslateTweetWorker)
        .to have_enqueued_sidekiq_job(feed.posts.first.id)
    end
  end
end
