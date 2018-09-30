require 'rails_helper'

RSpec.describe '/ping', type: :request do
  let(:feed) { feeds(:example) }
  let(:url) { 'https://example.org/' }
  let(:body) {
    XMLRPC::Create.new.methodCall('weblogUpdates.ping', 'title', url)
  }

  def do_ping
    post '/ping', params: body, headers: { 'Content-Type': 'text/xml' }
  end

  it 'enqueues a job to refresh the matching feed' do
    do_ping
    expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
  end

  it 'returns a successful response' do
    do_ping
    expected_response = XMLRPC::Create.new.methodResponse(
      true,
      flerror: false,
      message: 'Thanks for the ping!'
    )
    expect(response.body).to eq expected_response
  end

  context 'when the input URL is not normalized' do
    let(:url) { 'https://example.org' }

    it 'finds the feed by normalized URL' do
      do_ping
      expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
    end
  end

  context 'when the URL is for a different site' do
    let(:url) { 'https://example123.com' }

    it 'does not enqueue a job for the feed' do
      do_ping
      expect(RefreshFeedWorker).not_to have_enqueued_sidekiq_job(feed.id)
    end

    it 'returns a successful response anyway' do
      do_ping
      expected_response = XMLRPC::Create.new.methodResponse(
        true,
        flerror: false,
        message: 'Thanks for the ping!'
      )
      expect(response.body).to eq expected_response
    end
  end
end
