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

Capybara.default_max_wait_time = 30  # タイムアウトを延長
Capybara.disable_animation = true
Capybara.automatic_reload = false
Capybara.enable_aria_label = true

# 並行テストでの接続問題を軽減
Capybara.server = :puma, { Silent: true, Threads: "0:4" }
Capybara.reuse_server = true

# Configure retry for flaky tests
Minitest::Retry.use!(retry_count: 3, verbose: true) if ENV['CI']

class ActiveSupport::TestCase
  include VCRHelper

  # Run tests in parallel with specified workers (reduced for stability)
  parallelize(workers: ENV['CI'] ? 2 : :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    ActiveStorage::Current.host = 'http://localhost:3000' # https://github.com/rails/rails/issues/40855
    
    # Ensure ActiveStorage directories exist before each test
    FileUtils.mkdir_p(ActiveStorage::Blob.service.root) unless Dir.exist?(ActiveStorage::Blob.service.root)
    FileUtils.mkdir_p(ActiveStorage::Blob.services.fetch(:test_fixtures).root) unless Dir.exist?(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end

  teardown do
    ActiveStorage::Current.host = nil
    
    # Clean up ActiveStorage files created during this specific test
    begin
      # Only clean up files created in the last minute to avoid interfering with other concurrent tests
      cleanup_recent_files(ActiveStorage::Blob.service.root)
      cleanup_recent_files(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
    rescue => e
      # Ignore cleanup errors to prevent flaky test failures
      Rails.logger.debug "ActiveStorage cleanup warning: #{e.message}" if Rails.logger
    end
  end

  private

  def cleanup_recent_files(directory)
    return unless Dir.exist?(directory)
    
    # Use a more conservative approach - only clean up very recent files
    cutoff_time = 30.seconds.ago
    
    Dir.glob("#{directory}/**/*").each do |file|
      next unless File.file?(file)
      next unless File.mtime(file) > cutoff_time
      
      begin
        File.delete(file) if File.exist?(file)
      rescue Errno::ENOENT, Errno::EACCES => e
        # File already deleted or permission denied, ignore
        Rails.logger.debug "Could not delete #{file}: #{e.message}" if Rails.logger
      end
    end
    
    # Clean up empty directories
    Dir.glob("#{directory}/**/").reverse_each do |dir|
      next if dir == directory
      begin
        Dir.rmdir(dir) if Dir.exist?(dir) && Dir.empty?(dir)
      rescue Errno::ENOENT, Errno::ENOTEMPTY, Errno::EACCES
        # Directory not empty, doesn't exist, or permission denied - ignore
      end
    end
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
    # Add delay to ensure all tests have completed file operations
    sleep 0.1
    
    begin
      FileUtils.rm_rf(ActiveStorage::Blob.service.root) if Dir.exist?(ActiveStorage::Blob.service.root)
      FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root) if Dir.exist?(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
    rescue => e
      # Ignore final cleanup errors to prevent test suite failures
      puts "Warning: ActiveStorage final cleanup failed: #{e.message}"
    end
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
