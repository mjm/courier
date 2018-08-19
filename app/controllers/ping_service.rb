class PingService
  def self.call(env)
    server = XMLRPC::RackServer.new
    server.add_introspection
    server.add_handler('weblogUpdates', self.new)
    server.call(env)
  end

  def ping(title, url)
    p title, url
  end
end
