# frozen_string_literal: true

ENV["RAILS_ENV"] = 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'onceler'
require 'database_cleaner'
require 'rails-controller-testing'
require 'climate_control'

ActiveRecord::Migration.maintain_test_schema!

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }
Dir[Rails.root.join('spec', 'models', 'shared_examples', '**', '*.rb')].each { |f| require f }
Dir[Rails.root.join('spec', 'controllers', 'shared_examples', '*.rb')].each { |f| require f }

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  # If you follow the canonical directory structure and have
  # configured infer_spec_type_from_file_location!, RSpec will automatically
  # include the correct support functions for each type.
  # i.e. we don't need to add type: :controller to controller specs, etc.
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
  Kernel.srand config.seed

  config.use_transactional_fixtures = true

  config.filter_rails_from_backtrace!

  config.include ActiveRecordHelper
  config.include ControllerMacros, type: :controller
  config.include Onceler::BasicHelpers
end
