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
    response.stub(:body, 'class Product < ApplicationRecord; end') do
      Net::HTTP.stub(:get_response, lambda { |_uri, headers|
        assert_equal 'Bearer token-for-pjord', headers['Authorization']
        response
      }) do
        mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
          entries = ProductAiReviewer::GithubCodeFetcher.fetch(github_url)

          assert_equal 'class Product < ApplicationRecord; end', entries.first[:body]
        end
      end
    end
  end
end
