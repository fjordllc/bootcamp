# frozen_string_literal: true

require 'test_helper'

class API::NotificationsTest < ActionDispatch::IntegrationTest
  test 'GET /api/notifications.json' do
    get api_notifications_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/notifications/unread.json' do
    get api_unread_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_unread_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
