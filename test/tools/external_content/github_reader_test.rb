# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class ExternalContent::GithubReaderTest < ActiveSupport::TestCase
  include MockEnvHelper

  setup do
    Rails.cache.clear
    @reader = ExternalContent::GithubReader.new
  end

  test 'fetches GitHub pull request context and exposes raw URLs for follow-up lookups' do
    responses = {
      'https://api.github.com/repos/fjordllc/bootcamp/pulls/123' => {
        title: 'Add product review',
        body: 'レビュー機能を追加します',
        head: { sha: 'abc123', ref: 'feature/product-review' },
        base: { ref: 'main' }
      }.deep_stringify_keys.to_json,
      'https://api.github.com/repos/fjordllc/bootcamp/pulls/123/files' => [
        {
          filename: 'app/models/product.rb',
          status: 'modified',
          additions: 10,
          deletions: 2,
          patch: "@@ -1,3 +1,4 @@\n class Product < ApplicationRecord\n+  def reviewed? = true\n end"
        }
      ].map(&:deep_stringify_keys).to_json
    }

    stub_fetch_url(responses) do
      result = @reader.fetch('https://github.com/fjordllc/bootcamp/pull/123')

      assert_includes result, 'Add product review'
      assert_includes result, 'feature/product-review'
      assert_includes result, 'app/models/product.rb'
      assert_includes result, 'raw.githubusercontent.com/fjordllc/bootcamp/abc123/app/models/product.rb'
      assert_includes result, 'def reviewed? = true'
    end
  end

  test 'fetches GitHub blob file content' do
    stub_request(:get, 'https://raw.githubusercontent.com/fjordllc/bootcamp/main/app/models/product.rb')
      .to_return(status: 200, body: "class Product < ApplicationRecord\nend\n")

    result = @reader.fetch('https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb')

    assert_includes result, '# GitHub File'
    assert_includes result, '```rb'
    assert_includes result, 'class Product < ApplicationRecord'
  end

  test 'fetches GitHub directory entries' do
    entries = [
      {
        type: 'file',
        path: 'app/models/product.rb',
        html_url: 'https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb'
      }
    ].map(&:deep_stringify_keys).to_json

    stub_fetch_url(entries) do
      result = @reader.fetch('https://github.com/fjordllc/bootcamp/tree/main/app/models')

      assert_includes result, '# GitHub Directory'
      assert_includes result, 'file: app/models/product.rb'
    end
  end

  test 'rejects non GitHub URLs' do
    assert_equal 'GitHubのURLだけ取得できます。', @reader.fetch('https://example.com/file.rb')
  end

  test 'rejects api github URLs because direct API URLs are not supported' do
    assert_equal 'GitHubのURLだけ取得できます。', @reader.fetch('https://api.github.com/repos/fjordllc/bootcamp')
  end

  test 'encodes raw URLs for pull request file paths' do
    responses = {
      'https://api.github.com/repos/fjordllc/bootcamp/pulls/123' => {
        title: 'Add special file',
        body: nil,
        head: { sha: 'abc123', ref: 'feature/product-review' },
        base: { ref: 'main' }
      }.deep_stringify_keys.to_json,
      'https://api.github.com/repos/fjordllc/bootcamp/pulls/123/files' => [
        {
          filename: 'app/models/product #1.rb',
          status: 'added',
          additions: 1,
          deletions: 0,
          patch: nil
        }
      ].map(&:deep_stringify_keys).to_json
    }

    stub_fetch_url(responses) do
      result = @reader.fetch('https://github.com/fjordllc/bootcamp/pull/123')

      assert_includes result, 'raw.githubusercontent.com/fjordllc/bootcamp/abc123/app/models/product%20%231.rb'
    end
  end

  test 'sends Pjord GitHub token when it is configured' do
    mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
      headers = @reader.send(:github_request_headers)

      assert_equal 'Bearer token-for-pjord', headers['Authorization']
    end
  end

  private

  def stub_fetch_url(response)
    original = @reader.method(:fetch_url)
    @reader.define_singleton_method(:fetch_url) do |url|
      response.is_a?(Hash) ? response[url] : response
    end
    yield
  ensure
    @reader.define_singleton_method(:fetch_url, original)
  end
end
