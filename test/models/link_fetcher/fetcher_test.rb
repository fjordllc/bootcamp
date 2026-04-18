# frozen_string_literal: true

require 'test_helper'

module LinkFetcher
  class FetcherTest < ActiveSupport::TestCase
    test '.fetch returns a successful response for a valid URL' do
      VCR.use_cassette 'link_fetcher/fetcher/fetch/success' do
        valid_url = 'https://bootcamp.fjord.jp/'
        response = Fetcher.fetch(valid_url)

        assert response.is_a?(Net::HTTPSuccess)
        assert_includes response.body, '<title>プログラミングスクール FJORD BOOT CAMP（フィヨルドブートキャンプ）</title>'
      end
    end

    test '.fetch returns nil for an invalid_url' do
      VCR.use_cassette 'link_fetcher/fetcher/fetch/failure/invalid_url' do
        invalid_url = 'https://bootcamp.fjo.jp/'
        response = Fetcher.fetch(invalid_url)

        assert_nil response
      end
    end

    test '.fetch returns nil for a URL that should be blocked' do
      VCR.use_cassette 'link_fetcher/fetcher/fetch/failure/blocked_url' do
        cloud_metadata_endpoint = 'http://169.254.169.254'
        response = Fetcher.fetch(cloud_metadata_endpoint)

        assert_nil response
      end
    end

    test '.build_http' do
      secure_uri = Addressable::URI.parse('https://bootcamp.fjord.jp/').normalize
      http = Fetcher.build_http(secure_uri)

      assert_equal OpenSSL::SSL::VERIFY_PEER, http.verify_mode
      assert_equal Fetcher::DEFAULT_TIMEOUT, http.open_timeout
      assert_equal Fetcher::DEFAULT_TIMEOUT, http.read_timeout
      assert http.response_body_encoding
    end

    test '.build_redirect_url' do
      test_redirect_url = 'https://httpbin.org/redirect/1'
      mock_response = { 'location' => '/get' }
      redirect_url = Fetcher.build_redirect_url(test_redirect_url, mock_response)

      assert_equal 'https://httpbin.org/get', redirect_url
    end
  end
end
