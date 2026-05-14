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

  test 'GET /api/notifications.json?status=unread' do
    get api_notifications_path(status: 'unread', format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(status: 'unread', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/notifications/:id/read.json' do
    token = create_token('kimura', 'testtest')
    notification = notifications('notification_mentioned_and_unread_1')

    post read_api_notification_path(notification, format: :json),
         headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    assert_equal notification.id, response.parsed_body['id']
    assert response.parsed_body['read']
    assert notification.reload.read?
  end

  test 'POST /api/notifications/read_by_category.json' do
    token = create_token('kimura', 'testtest')

    post read_by_category_api_notifications_path(format: :json),
         headers: { 'Authorization' => "Bearer #{token}" },
         params: { target: 'mention' }

    assert_response :ok
    assert_equal 2, response.parsed_body['count']
    assert notifications('notification_mentioned_and_unread_1').reload.read?
    assert notifications('notification_mentioned_and_unread_2').reload.read?
    assert_not notifications(:notification_watching).reload.read?
  end

  test 'POST /api/notifications/read_all.json' do
    token = create_token('kimura', 'testtest')
    unread_count = users(:kimura).notifications.unreads.count

    post read_all_api_notifications_path(format: :json),
         headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    assert_equal unread_count, response.parsed_body['count']
    assert_equal 0, users(:kimura).notifications.unreads.count
  end

  test 'returns not found when reading other user notification' do
    token = create_token('kimura', 'testtest')

    post read_api_notification_path(notifications(:notification_submitted), format: :json),
         headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :not_found
    assert_equal '通知が見つかりません。', response.parsed_body['message']
    assert_not notifications(:notification_submitted).reload.read?
  end
end
