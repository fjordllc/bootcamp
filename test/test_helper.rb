# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'active_support/core_ext/string'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/mock'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'abstract_notifier/testing/minitest'
require 'webmock/minitest'
require 'timeout'

Capybara.default_max_wait_time = 15
Capybara.disable_animation = true
Capybara.automatic_reload = false
Capybara.enable_aria_label = true

# Configure retry for flaky tests
Minitest::Retry.use!(retry_count: 3, verbose: true) if ENV['CI']

# Add timeout for long-running tests in CI
if ENV['CI']
  module TimeoutExtension
    def run
      Timeout.timeout(300) do # 5 minutes per test maximum
        super
      end
    rescue Timeout::Error
      skip "Test timed out after 5 minutes"
    end
  end

  Minitest::Test.prepend(TimeoutExtension)
end

class ActiveSupport::TestCase
  include VCRHelper

  # Run tests in parallel with specified workers
  if ENV['CI']
    parallelize(workers: ENV.fetch('PARALLEL_WORKERS', 1).to_i)
  else
    parallelize(workers: :number_of_processors)
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    Rails.application.routes.default_url_options[:host] = 'localhost'
    Rails.application.routes.default_url_options[:port] = 3000
    Rails.application.config.active_storage.default_url_options = { host: 'localhost', port: 3000 }
    # Rails 7.2でActiveStorage::Currentにurl_optionsを設定（ポートは固定しない）
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000 }
  end

  teardown do
    Rails.application.routes.default_url_options.delete(:host)
    Rails.application.routes.default_url_options.delete(:port)
    ActiveStorage::Current.url_options = nil
  end

  # Rails 7 Active Storage test setup
  # 参考： https://guides.rubyonrails.org/active_storage_overview.html#discarding-files-created-during-tests
  base_blob_root = ActiveStorage::Blob.service.root.to_s
  base_fixtures_root = ActiveStorage::Blob.services.fetch(:test_fixtures).root.to_s

  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = File.join(base_blob_root, "storage-#{i}")
    ActiveStorage::Blob.services.fetch(:test_fixtures).root = File.join(base_fixtures_root, "fixtures-#{i}")
  end

  Minitest.after_run do
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  ActionDispatch::SystemTesting::Server.silence_puma = true
end

# Rails 7用のActiveStorage::Blob.fixture メソッドを実装
module BlobFixtureSet
  def fixture(filename:, service_name: nil, **attributes) # rubocop:disable Lint/UnusedMethodArgument
    blob = new(
      filename:,
      key: generate_unique_secure_token
    )

    file_path = Rails.root.join("test/fixtures/files/#{filename}")

    io = file_path.open
    blob.unfurl(io)
    blob.assign_attributes(attributes)
    blob.upload_without_unfurling(io)
    io.close

    blob.attributes.transform_values { |values| values.is_a?(Hash) ? values.to_json : values }.compact.to_json
  end
end
ActiveStorage::Blob.extend BlobFixtureSet
