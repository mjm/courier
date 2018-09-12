class PingService
  def self.call(env)
    server = XMLRPC::RackServer.new
    server.add_introspection
    server.add_handler('weblogUpdates', new)
    server.call(env)
  end

  def ping(_title, url)
    Feed.by_home_page(url).each(&:refresh)
    { flerror: false, message: 'Thanks for the ping!' }
  end
end
