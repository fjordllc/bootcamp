# frozen_string_literal: true

require 'test_helper'

class API::UserIconUrlsTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'GET /api/user_icon_urls.json' do
    get api_user_icon_urls_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_user_icon_urls_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
