# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
# Suppress VIPS/GLib warnings in test environment
ENV['G_MESSAGES_DEBUG'] = ''

# Aggressive GC settings for CI to prevent OOM
if ENV['CI']
  ENV['RUBY_GC_HEAP_GROWTH_FACTOR'] = '1.1'
  ENV['RUBY_GC_MALLOC_LIMIT'] = '16000000'
  ENV['RUBY_GC_MALLOC_LIMIT_MAX'] = '32000000'
  ENV['RUBY_GC_OLDMALLOC_LIMIT'] = '16000000'
  ENV['RUBY_GC_OLDMALLOC_LIMIT_MAX'] = '32000000'
end

require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/mock'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'abstract_notifier/testing/minitest'
require 'webmock/minitest'

# Ensure AbstractNotifier uses test mode
AbstractNotifier.delivery_mode = :test

Capybara.default_max_wait_time = 15
Capybara.disable_animation = true
Capybara.automatic_reload = false
Capybara.enable_aria_label = true

# Configure retry for flaky tests
Minitest::Retry.use!(retry_count: 3, verbose: true) if ENV['CI']

# CI test logging helper - writes directly to fd 2 (stderr) with sync
# This ensures output is immediately visible in CI logs
module CITestLogger
  def self.log(message)
    return unless ENV['CI']

    timestamp = Time.zone.now.strftime('%H:%M:%S')
    File.open('/dev/stderr', 'a') do |f|
      f.sync = true
      f.puts "[#{timestamp}] #{message}"
    end
  end
end

class ActiveSupport::TestCase
  include VCRHelper

  # Run tests in parallel
  # In CI: Disable Rails parallelization - CircleCI handles parallelism via parallelism: 3
  # This avoids DRb/fork complexity that can cause test hangs (Rails issue #55513)
  # Locally: Use number_of_processors for faster test execution
  unless ENV['CI']
    parallelize(workers: :number_of_processors)

    # Setup for each parallel process
    parallelize_setup do |_worker|
      ActiveStorage::Current.url_options = { protocol: 'http', host: 'localhost', port: '3000' }
      ActiveJob::Base.queue_adapter = :test
    end
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    ActiveStorage::Current.url_options = { protocol: 'http', host: 'localhost', port: '3000' }
    ActiveJob::Base.queue_adapter = :test
    CITestLogger.log("[TEST START] #{self.class.name}##{name}")
  end

  teardown do
    CITestLogger.log("[TEST END] #{self.class.name}##{name}")
    # Force garbage collection in CI to prevent OOM kills
    GC.start if ENV['CI']
  end
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper

  setup do
    CITestLogger.log("[TEST START] #{self.class.name}##{name}")
  end

  teardown do
    CITestLogger.log("[TEST END] #{self.class.name}##{name}")
    # Force garbage collection in CI to prevent OOM kills
    GC.start if ENV['CI']
  end
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  ActionDispatch::SystemTesting::Server.silence_puma = true
end
