# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class ProductAiReviewer::GithubCodeFetcherTest < ActiveSupport::TestCase
  include MockEnvHelper

  test '.fetch converts GitHub blob links to raw URLs and returns code entries' do
    github_url = 'https://github.com/fjordllc/bootcamp/blob/main/app/models/product.rb'

    ProductAiReviewer::GithubCodeFetcher.stub(:fetch_url, lambda { |url|
      assert_equal 'https://raw.githubusercontent.com/fjordllc/bootcamp/main/app/models/product.rb', url
      'class Product < ApplicationRecord; end'
    }) do
      entries = ProductAiReviewer::GithubCodeFetcher.fetch("コード: #{github_url}")

      assert_equal 1, entries.size
      assert_equal github_url, entries.first[:url]
      assert_equal 'rb', entries.first[:language]
      assert_equal 'class Product < ApplicationRecord; end', entries.first[:body]
    end
  end

  test '.fetch ignores non-code GitHub links' do
    ProductAiReviewer::GithubCodeFetcher.stub(:fetch_url, ->(_url) { raise 'should not fetch' }) do
      assert_empty ProductAiReviewer::GithubCodeFetcher.fetch('https://github.com/fjordllc/bootcamp/issues/1')
    end
  end

  test '.fetch sends Pjord GitHub token when it is configured' do
    github_url = 'https://raw.githubusercontent.com/fjordllc/bootcamp/main/app/models/product.rb'
    response = Net::HTTPSuccess.new('1.1', '200', 'OK')
    http = Minitest::Mock.new
    headers = {
      'User-Agent' => 'fjord-bootcamp-pjord',
      'Authorization' => 'Bearer token-for-pjord'
    }
    http.expect(:get, response, ['/fjordllc/bootcamp/main/app/models/product.rb', headers])

    response.stub(:body, 'class Product < ApplicationRecord; end') do
      Net::HTTP.stub(:start, lambda { |host, port, options, &block|
        assert_equal 'raw.githubusercontent.com', host
        assert_equal 443, port
        assert options[:use_ssl]
        assert_equal ProductAiReviewer::GithubCodeFetcher::OPEN_TIMEOUT, options[:open_timeout]
        assert_equal ProductAiReviewer::GithubCodeFetcher::READ_TIMEOUT, options[:read_timeout]
        block.call(http)
        response
      }) do
        mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
          entries = ProductAiReviewer::GithubCodeFetcher.fetch(github_url)

          assert_equal 'class Product < ApplicationRecord; end', entries.first[:body]
        end
      end
    end

    http.verify
  end
end
