# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class ProductAiReviewer::GithubCodeFetcherTest < ActiveSupport::TestCase
  include MockEnvHelper

  setup do
    Rails.cache.clear
  end

  test '.fetch converts GitHub blob links to raw URLs and returns code entries' do
    github_url = 'https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb'
    raw_url = 'https://raw.githubusercontent.com/fjordllc/bootcamp/main/app/models/product.rb'

    assert_equal raw_url, ProductAiReviewer::GithubCodeFetcher.send(:raw_github_url, github_url)
  end

  test '.fetch ignores non-code GitHub links' do
    assert_empty ProductAiReviewer::GithubCodeFetcher.fetch('https://github.com/fjordllc/bootcamp/issues/1')
  end

  test '.fetch normalizes fetched body encoding to UTF-8' do
    binary_body = 'class Product < ApplicationRecord; end'.b
    normalized_body = ProductAiReviewer::GithubCodeFetcher.send(:normalize_body, binary_body)

    assert_equal Encoding::UTF_8, normalized_body.encoding
    assert_equal 'class Product < ApplicationRecord; end', normalized_body
  end

  test '.fetch sends Pjord GitHub token when it is configured' do
    mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
      headers = ProductAiReviewer::GithubCodeFetcher.send(:github_request_headers)

      assert_equal 'Bearer token-for-pjord', headers['Authorization']
    end
  end

  test '.fetch uses explicit timeouts for GitHub requests' do
    github_url = 'https://raw.githubusercontent.com/fjordllc/bootcamp/main/app/models/product.rb'
    captured_options = nil

    Net::HTTP.stub(:start, lambda { |_host, _port, *args, **kwargs, &block|
      captured_options = kwargs.presence || args.first || {}
      response = Net::HTTPSuccess.new('1.1', '200', 'OK')
      http = Minitest::Mock.new
      http.expect(:get, response, ['/fjordllc/bootcamp/main/app/models/product.rb', { 'User-Agent' => 'fjord-bootcamp-pjord' }])
      response.define_singleton_method(:body) { 'class Product < ApplicationRecord; end' }

      block.call(http)
    }) do
      body = ProductAiReviewer::GithubCodeFetcher.send(:fetch_url, github_url)

      assert_equal 'class Product < ApplicationRecord; end', body
    end

    assert_equal ProductAiReviewer::GithubCodeFetcher::OPEN_TIMEOUT, captured_options[:open_timeout]
    assert_equal ProductAiReviewer::GithubCodeFetcher::READ_TIMEOUT, captured_options[:read_timeout]
  end
end
