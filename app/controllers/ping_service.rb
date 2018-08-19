class PingService
  def self.call(env)
    server = XMLRPC::RackServer.new
    server.add_introspection
    server.add_handler('weblogUpdates', new)
    server.call(env)
  end

  def ping(title, url)
    feeds_client.ping(title: title, url: url)
    { flerror: false, message: 'Thanks for the ping!' }
  end

  private

  def feeds_client
    Courier::FeedsClient.connect
  end
end
