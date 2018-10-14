require 'rails_helper'
require 'webmock/rspec'

RSpec.describe PostTweetsWorker, type: :worker do
  let(:post) { create(:post, :subscribed) }
  let(:tweets_to_post) {
    [create(:tweet, :queued, post: post, body: 'First tweet!'),
     create(:tweet, :queued, post: post, body: 'Second tweet!')]
  }
  let(:ids) { tweets_to_post.map(&:id) }

  STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze
  UPLOAD_URL = 'https://upload.twitter.com/1.1/media/upload.json'.freeze

  before do
    subject.jid = 'abc'
    stub_request(:post, STATUS_UPDATE_URL).to_return(
      body: File.new(file_fixture('tweet.json')),
      headers: { content_type: 'application/json; charset=utf8' }
    )
  end

  it 'sends the tweets to Twitter' do
    subject.perform(ids)
    expect(
      a_request(:post, STATUS_UPDATE_URL).with(
        body: { status: 'First tweet!', media_ids: '' }
      )
    ).to have_been_made
    expect(
      a_request(:post, STATUS_UPDATE_URL).with(
        body: {
          status: 'Second tweet!',
          media_ids: '',
          in_reply_to_status_id: '540897316908331009'
        }
      )
    ).to have_been_made
  end

  it 'moves the tweets to the posted status' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:status))
      .to all(eq 'posted')
  end

  it 'saves the timestamp when the tweet was posted' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:posted_at))
      .not_to include(be_nil)
  end

  it 'saves the ID of the tweet for linking to later' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:posted_tweet_id))
      .to all(eq '540897316908331009')
  end

  context 'when the tweet is canceled' do
    let(:tweets_to_post) { [create(:tweet, :queued, :canceled, post: post)] }

    it 'does not update the status of the canceled tweet' do
      subject.perform(ids)
      expect(tweets_to_post.first.reload).to be_canceled
    end

    it 'does not post the tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL)).not_to have_been_made
    end
  end

  context 'when the tweet is already posted' do
    let(:tweets_to_post) { [create(:tweet, :queued, :posted, post: post)] }

    it 'does not post the tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL)).not_to have_been_made
    end
  end

  context 'when the tweet was queued for a different job' do
    before { subject.jid = 'slfk' }

    it 'does not update the status of the tweet' do
      subject.perform(ids)
      expect(tweets_to_post.first.reload).to be_draft
    end

    it 'does not post the tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL)).not_to have_been_made
    end
  end

  context 'when the tweet has a media URL' do
    let(:tweets_to_post) { [create(:tweet, :queued, :image)] }
    let(:image_url) { 'https://example.org/media/foo.jpg' }

    before do
      stub_request(:get, image_url).to_return(body: 'asdf')
      stub_request(:post, UPLOAD_URL).to_return(
        body: File.new(file_fixture('upload.json')),
        headers: { content_type: 'application/json; charset=utf8' }
      )
    end

    it 'downloads the file at the media URL' do
      subject.perform(ids)
      expect(a_request(:get, image_url)).to have_been_made
    end

    it 'uploads the file to Twitter' do
      subject.perform(ids)
      expect(a_request(:post, UPLOAD_URL)).to have_been_made
    end

    it 'attaches the uploaded media item to the posted tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL)
        .with(
          body: {
            status: 'This is some content.',
            media_ids: '470030289822314497'
          }
        )).to have_been_made
    end
  end
end
