# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/mock'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'abstract_notifier/testing/minitest'
require 'webmock/minitest'

Capybara.default_max_wait_time = 10
Capybara.disable_animation = true
Minitest::Retry.use! if ENV['CI']

Capybara.register_driver :selenium_chrome_headless_with_clipboard do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << 'headless'
  options.args << 'disable-gpu'
  options.args << 'no-sandbox'
  options.args << 'enable-blink-features=Clipboard'

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end
Capybara.javascript_driver = :selenium_chrome_headless_with_clipboard

class ActiveSupport::TestCase
  include VCRHelper

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    ActiveStorage::Current.host = 'http://localhost:3000' # https://github.com/rails/rails/issues/40855
  end

  teardown do
    ActiveStorage::Current.host = nil
  end

  # Rails7になったら以下のように修正する
  #   parallelize_setup do |i|
  #     ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}/storage-#{i}"
  #     ActiveStorage::Blob.services.fetch(:test_fixtures).root = "#{ActiveStorage::Blob.services.fetch(:test_fixtures).root}/fixtures-#{i}"
  #   end
  # 参考： https://guides.rubyonrails.org/active_storage_overview.html#discarding-files-created-during-tests
  parallelize_setup do |i|
    ActiveStorage::Blob.service.instance_variable_set(:@root, "#{ActiveStorage::Blob.service.root}/storage-#{i}")
    ActiveStorage::Blob.services.fetch(:test_fixtures).instance_variable_set(:@root, "#{ActiveStorage::Blob.services.fetch(:test_fixtures).root}/fixtures-#{i}")
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

# Rails 7 の ActiveStorage::FixtureSet.blob と同様の機能を実装
# Pull Request #4182(https://github.com/fjordllc/bootcamp/pull/4182) でRails 7 への移行完了後に削除する
# => test/fixtures/active_storage/blobs.yml でActiveStorage::FixtureSet.blob を使うように変更する
module BlobFixtureSet
  def fixture(filename:, **attributes)
    blob = new(
      filename:,
      key: generate_unique_secure_token
    )
    io = Rails.root.join("test/fixtures/files/#{filename}").open
    blob.unfurl(io)
    blob.assign_attributes(attributes)
    blob.upload_without_unfurling(io)

    blob.attributes.transform_values { |values| values.is_a?(Hash) ? values.to_json : values }.compact.to_json
  end
end
ActiveStorage::Blob.extend BlobFixtureSet
