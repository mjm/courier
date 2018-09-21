class ActionDispatch::Routing::Mapper
  def service(service_class)
    mount service_class.service, at: service_class.path
  end
end
