# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'webdrivers' unless RUBY_PLATFORM.match?(/aarch64/)

Capybara.default_max_wait_time = 5
Capybara.disable_animation = true
Webdrivers.cache_time = 86_400 if defined?(Webdrivers)
Minitest::Retry.use! if ENV['CI']
Selenium::WebDriver.logger.ignore(:browser_options) # TODO: Remove it when capybara-3.36.0 greater is released.

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end
