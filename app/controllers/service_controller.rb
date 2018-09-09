class ServiceController
  class << self
    def service
      @service ||= create_service
    end

    def path
      "/api/#{service.full_name}"
    end

    private

    def create_service
      service_class.new(new).tap do |service|
        service.before do |rack_env, env|
          # TODO: add auth info to the env
        end
      end
    end

    def service_class
      name.sub(/Controller$/, 'Service').constantize
    end
  end
end
