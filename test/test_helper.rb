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

# Configure retry for flaky tests (CI or when MINITEST_RETRY_COUNT is set)
if ENV['CI'] || ENV['MINITEST_RETRY_COUNT']
  retry_count = ENV.fetch('MINITEST_RETRY_COUNT', 3).to_i
  Minitest::Retry.use!(retry_count:, verbose: true)
end

class ActiveSupport::TestCase
  include VCRHelper

  # Parallel testing configuration:
  # - CI: Disabled - CircleCI handles parallelism via its own parallelism setting
  # - Local: Disabled - DRb/fork causes test hangs (Rails issue #55513)
  # To enable parallel tests locally, use: PARALLEL_WORKERS=4 bin/rails test
  parallelize(workers: ENV.fetch('PARALLEL_WORKERS', 1).to_i)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    ActiveStorage::Current.url_options = { protocol: 'http', host: 'localhost', port: '3000' }
    ActiveJob::Base.queue_adapter = :test
    AbstractNotifier.delivery_mode = :test
    AbstractNotifier::Testing::Driver.clear
  end
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  ActionDispatch::SystemTesting::Server.silence_puma = true
end
