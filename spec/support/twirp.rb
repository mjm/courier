RSpec::Matchers.define :be_a_twirp_error do |code, msg = nil|
  match do |actual|
    actual.is_a?(Twirp::Error) &&
      (actual.code == code) &&
      (msg.nil? || msg == actual.msg)
  end

  failure_message do |actual|
    if msg
      "expected #{actual.inspect} to be a #{code} error" \
        " with message #{msg.inspect}"
    else
      "expected #{actual.inspect} to be a #{code} error"
    end
  end
end

RSpec.shared_examples 'an unauthenticated request' do
  context 'when no user is currently logged in' do
    let(:env) { {} }

    it 'returns an unauthenticated response' do
      expect(response).to be_a_twirp_error :unauthenticated
    end
  end
end

RSpec.shared_examples 'a request from another user' do
  context 'when a different user is logged in' do
    let(:current_user) { create(:user) }

    it 'returns a forbidden response' do
      expect(response).to be_a_twirp_error :permission_denied
    end
  end
end

module RPCHelpers
  def rpc_method(name)
    let(:method_name) { name }
    let(:response) { subject.call_rpc(method_name, request, env) }
  end

  def self.extend_object(base)
    super
    base.subject { described_class.service }
    base.let(:request) { {} }
    base.let(:current_user) { create(:user) }
    base.let(:env) { { user: current_user } }
  end
end
