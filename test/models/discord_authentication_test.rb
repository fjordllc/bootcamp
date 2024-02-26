# frozen_string_literal: true

require 'test_helper'

class DiscordAuthenticationTest < ActiveSupport::TestCase
  test '.fetch_access_token' do
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '{"access_token": "mock_token"}')

    mock_http = Minitest::Mock.new
    mock_http.expect(:use_ssl=, nil, [TrueClass])
    mock_http.expect(:request, mock_response, [Object])

    mock_request = Minitest::Mock.new
    mock_request.expect(:[]=, nil, [String, String])
    mock_request.expect(:set_form_data, nil, [Hash])

    Net::HTTP.stub(:new, mock_http) do
      Net::HTTP::Post.stub(:new, mock_request) do
        result = DiscordAuthentication.fetch_access_token('code', 'uri')
        assert_equal 'mock_token', result
      end
    end
  end

  test '.fetch_discord_account_name' do
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '{"username": "komagata_discord"}')

    mock_http = Minitest::Mock.new
    mock_http.expect(:use_ssl=, nil, [TrueClass])
    mock_http.expect(:request, mock_response, [Object])

    mock_request = Minitest::Mock.new
    mock_request.expect(:[]=, nil, [String, String])

    Net::HTTP.stub(:new, mock_http) do
      Net::HTTP::Get.stub(:new, mock_request) do
        result = DiscordAuthentication.fetch_discord_account_name('token')
        assert_equal 'komagata_discord', result
      end
    end
  end
end
