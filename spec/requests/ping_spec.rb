require 'rails_helper'

RSpec.describe '/ping', type: :request do
  let!(:feed) { create(:feed, :loaded) }
  let(:url) { feed.home_page_url }
  let(:body) {
    XMLRPC::Create.new.methodCall('weblogUpdates.ping', 'title', url)
  }

  # Creating the feed will enqueue a job
  before { Sidekiq::Worker.clear_all }

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
    let(:url) { feed.home_page_url.chop }

    it 'finds the feed by normalized URL' do
      do_ping
      expect(RefreshFeedWorker).to have_enqueued_sidekiq_job(feed.id)
    end
  end

  context 'when the URL is for a different site' do
    let(:url) { 'https://example123.org' }

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
