# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
# Suppress VIPS/GLib warnings in test environment
ENV['G_MESSAGES_DEBUG'] = ''
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/mock'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'abstract_notifier/testing/minitest'
require 'webmock/minitest'

Capybara.default_max_wait_time = 15
Capybara.disable_animation = true
Capybara.automatic_reload = false
Capybara.enable_aria_label = true

# Configure retry for flaky tests
Minitest::Retry.use!(retry_count: 3, verbose: true) if ENV['CI']

class ActiveSupport::TestCase
  include VCRHelper

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup for each parallel process
  parallelize_setup do |_worker|
    ActiveStorage::Current.url_options = { protocol: 'http', host: 'localhost', port: '3000' }
    ActiveJob::Base.queue_adapter = :test
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    ActiveStorage::Current.url_options = { protocol: 'http', host: 'localhost', port: '3000' }
    ActiveJob::Base.queue_adapter = :test
  end
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  ActionDispatch::SystemTesting::Server.silence_puma = true
end
