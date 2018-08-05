require 'base64'

Rails.application.config.x.jwt.secret = Base64.decode64(ENV['JWT_SECRET'])
Rails.application.config.x.jwt.algorithm = 'HS256'
Rails.application.config.x.jwt.service_token = JWT.encode(
  { sub: 'courier-gateway', roles: %i[service] },
  Rails.application.config.x.jwt.secret,
  Rails.application.config.x.jwt.algorithm
)
