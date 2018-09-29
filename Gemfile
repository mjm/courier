source 'https://rubygems.org'
# git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'addressable'
gem 'bunny'
gem 'devise'
gem 'discard', '~> 1.0'
gem 'faraday'
gem 'faraday_middleware'
gem 'jwt'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'pg'
gem 'sidekiq', '~> 5.0'
gem 'sidekiq-unique-jobs', '~> 5.0'
gem 'stripe'
gem 'stripe_event'
gem 'twirp'
gem 'twitter'
gem 'typhoeus'
gem 'xmlrpc'
gem 'xmlrpc-rack_server'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'action-cable-testing'
  gem 'byebug'
  gem 'rspec-rails', '~> 3.8'
  gem 'stripe-ruby-mock', '~> 2.5', require: 'stripe_mock'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rspec-sidekiq'
end
