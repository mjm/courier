# This allows us to configure staging to only be able to actually post to
# Twitter for a specified set of users. This is important because the staging
# app is publicly accessible, but uses Stripe's test environment, so someone
# could potentially sign up there and use Courier for free with fake payment
# information.

require 'allowed_users'
Rails.configuration.allowed_users = AllowedUsers.new
