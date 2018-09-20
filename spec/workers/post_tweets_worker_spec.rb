require 'rails_helper'

require 'webmock/rspec'

RSpec.describe PostTweetsWorker, type: :worker do
  let(:tweets_to_post) do
    [
      tweets(:alice_example_status),
      tweets(:alice_example_status2)
    ]
  end
  let(:ids) { tweets_to_post.map(&:id) }

  STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze

  before do
    subject.jid = 'abc'
    stub_request(:post, STATUS_UPDATE_URL).to_return(
      body: File.new(file_fixture('tweet.json')),
      headers: { content_type: 'application/json; charset=utf8' }
    )
  end

  it 'sends the tweets to Twitter' do
    subject.perform(ids)
    expect(a_request(:post, STATUS_UPDATE_URL).with(
      body: { status: 'This is an example status post.', media_ids: '' }
    )).to have_been_made
    expect(a_request(:post, STATUS_UPDATE_URL).with(
      body: { status: 'This is a second tweet for the same post.', media_ids: '' }
    )).to have_been_made
  end

  it 'moves the tweets to the posted status' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:status)).to all(eq 'posted')
  end

  it 'saves the timestamp when the tweet was posted' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:posted_at)).not_to include(be_nil)
  end

  it 'saves the ID of the tweet for linking to later' do
    subject.perform(ids)
    expect(tweets_to_post.each(&:reload).map(&:posted_tweet_id)).to all(eq '540897316908331009')
  end

  context 'when the tweet is canceled' do
    before do
      tweets_to_post.first.tap do |t|
        t.canceled!
        t.reload
      end
    end

    it 'does not update the status of the canceled tweet' do
      subject.perform(ids)
      expect(tweets.first.reload).to be_canceled
    end

    it 'does not post the tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL).with(
        body: { status: 'This is an example status post.' }
      )).not_to have_been_made
    end
  end

  context 'when the tweet is already posted' do
    before do
      tweets.first.tap do |t|
        t.posted!
        t.reload
      end
    end

    it 'does not post the tweet' do
      subject.perform(ids)
      expect(a_request(:post, STATUS_UPDATE_URL).with(
        body: { status: 'This is an example status post.' }
      )).not_to have_been_made
    end
  end
end
