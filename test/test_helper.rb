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

# Rails 7.2: フィクスチャのtimestampsを自動で埋める
module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      alias_method :original_build_fixture_sql, :build_fixture_sql

      def build_fixture_sql(fixtures, table_name)
        columns = schema_cache.columns_hash(table_name)
        timestamp_columns = ['created_at', 'created_on', 'updated_at', 'updated_on']
        now = Time.current.to_fs(:db)

        # timestampカラムが存在し、fixtureに値が設定されていない場合は現在時刻を設定
        fixtures = fixtures.map do |fixture|
          fixture = fixture.stringify_keys
          timestamp_columns.each do |col|
            if columns.key?(col) && !fixture.key?(col)
              fixture[col] = now
            end
          end
          fixture
        end

        original_build_fixture_sql(fixtures, table_name)
      end
    end
  end
end

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

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    # Rails 7: ActiveStorage::Current.host= is deprecated, use url_options= instead
    ActiveStorage::Current.url_options = { host: 'localhost', port: 3000, protocol: 'http' }

    # Rails 7.2: テスト環境でロケールとタイムゾーンを設定
    I18n.locale = :ja
    Time.zone = 'Asia/Tokyo'
  end

  teardown do
    ActiveStorage::Current.url_options = nil
  end

  # 参考： https://guides.rubyonrails.org/active_storage_overview.html#discarding-files-created-during-tests
  parallelize_setup do |i|
    original_root = ActiveStorage::Blob.service.instance_variable_get(:@root)
    ActiveStorage::Blob.service.instance_variable_set(:@root, Pathname.new(original_root).join("storage-#{i}"))

    original_fixtures_root = ActiveStorage::Blob.services.fetch(:test_fixtures).instance_variable_get(:@root)
    ActiveStorage::Blob.services.fetch(:test_fixtures).instance_variable_set(:@root, Pathname.new(original_fixtures_root).join("fixtures-#{i}"))
  end

  Minitest.after_run do
    FileUtils.rm_rf(ActiveStorage::Blob.service.instance_variable_get(:@root))
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).instance_variable_get(:@root))
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
