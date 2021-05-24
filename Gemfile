# frozen_string_literal: true

source 'https://rubygems.org'

gem 'health_check'
gem "httparty"
gem "json-jwt"
gem 'pg', '~> 0.21.0'
gem 'rails', '~> 6.0.3.6'
gem 'rack', '~> 2.1'
gem 'browser', '~> 2.6.1'
gem 'json_schemer'
gem 'seedbank', '~> 0.3.0' # Used for seeding different environments
gem 'redis', '~>3.2'
gem 'active_model_serializers', '~> 0.9.3'

# Set 3rd party cookies in Safari
gem 'canvas_lti_third_party_cookies', '~> 0.4.0'

group :development, :test do
  gem 'byebug'
  gem 'listen', '~> 3.1.5'
end

group :test do
  gem 'climate_control'
  gem 'database_cleaner'
  gem 'gergich', require: false
  gem "once-ler", "~> 0.1.4"
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
  gem 'simplecov-rcov', require: false
  gem 'timecop'
end
