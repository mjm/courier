# This allows us to configure staging to only be able to actually post to
# Twitter for a specified set of users. This is important because the staging
# app is publicly accessible, but uses Stripe's test environment, so someone
# could potentially sign up there and use Courier for free with fake payment
# information.

if ENV['ALLOWED_TWITTER_USERS'].present?
  allowed_users = ENV['ALLOWED_TWITTER_USERS'].split(',')
  Rails.configuration.allowed_users_filter =
    ->(username) { allowed_users.include? username }
  Rails.logger.info \
    "Only allowing Twitter users: #{allowed_users.join(' ')}"
else
  Rails.configuration.allowed_users_filter = ->(_) { true }
  Rails.logger.info 'Allowing all Twitter users'
end
