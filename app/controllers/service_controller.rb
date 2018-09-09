class ServiceController
  include ServiceHelper

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
          env[:warden] = rack_env['warden']
          env[:user] = env[:warden].user
        end
      end
    end

    def service_class
      name.sub(/Controller$/, 'Service').constantize
    end
  end
end
