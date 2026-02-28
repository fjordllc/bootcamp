# frozen_string_literal: true

require 'test_helper'

class API::NotificationsDetailTest < ActionDispatch::IntegrationTest
  fixtures :users, :notifications

  test 'unread notifications response has all required fields with correct types' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(status: 'unread', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    assert json.key?('notifications'), 'Missing top-level notifications key'
    assert json.key?('total_pages'), 'Missing top-level total_pages key'
    assert_kind_of Array, json['notifications']
    assert_kind_of Integer, json['total_pages']
    assert json['total_pages'].positive?, 'total_pages should be >= 1'
    assert json['notifications'].size.positive?, 'Should have at least one unread notification'

    json['notifications'].each_with_index do |n, i|
      ctx = "Notification ##{i} (id=#{n['id']})"

      # Required fields with type checks
      assert_kind_of Integer, n['id'], "#{ctx}: id should be Integer"
      assert_kind_of String, n['kind'], "#{ctx}: kind should be String"
      assert_includes Notification.kinds.keys, n['kind'], "#{ctx}: kind '#{n['kind']}' is not a valid enum value"
      assert_kind_of String, n['message'], "#{ctx}: message should be String"
      assert n['message'].present?, "#{ctx}: message should not be blank"
      assert_kind_of String, n['path'], "#{ctx}: path should be String"
      assert n['path'].start_with?('/'), "#{ctx}: path should start with /"
      assert_not n['read'], "#{ctx}: read should be false for unread"
      assert_kind_of String, n['created_at'], "#{ctx}: created_at should be String"
      assert_nothing_raised { Time.zone.parse(n['created_at']) }

      # Sender validation
      sender = n['sender']
      assert sender.present?, "#{ctx}: sender should not be nil"
      sender_ctx = "#{ctx} sender (#{sender['login_name']})"

      assert_kind_of Integer, sender['id'], "#{sender_ctx}: id should be Integer"
      assert_kind_of String, sender['login_name'], "#{sender_ctx}: login_name should be String"
      assert sender['login_name'].present?, "#{sender_ctx}: login_name should not be blank"
      assert_match(/\A[a-zA-Z0-9_-]+\z/, sender['login_name'], "#{sender_ctx}: login_name has invalid chars")
      assert_kind_of String, sender['avatar_url'], "#{sender_ctx}: avatar_url should be String"
      assert sender['avatar_url'].present?, "#{sender_ctx}: avatar_url should not be blank"
      assert sender.key?('company'), "#{sender_ctx}: company key should exist"

      # Company validation (can be null but structure must be correct when present)
      company = sender['company']
      if company.present?
        assert company.key?('logo_url'), "#{sender_ctx}: company should have logo_url"
        assert company.key?('url'), "#{sender_ctx}: company should have url"
        assert_kind_of String, company['url'], "#{sender_ctx}: company url should be String"
      end

      # Verify sender references a real user
      user = User.find_by(id: sender['id'])
      assert user.present?, "#{sender_ctx}: sender id #{sender['id']} not found in DB"
      assert_equal user.login_name, sender['login_name'], "#{sender_ctx}: login_name mismatch with DB"
    end
  end

  test 'all notifications (read + unread) response is valid' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    notifications = json['notifications']
    assert_kind_of Array, notifications
    assert notifications.size.positive?, 'Should have notifications'

    # Verify ordering: should be newest first
    timestamps = notifications.map { |n| Time.zone.parse(n['created_at']) }
    assert_equal timestamps, timestamps.sort.reverse, 'Notifications should be ordered newest first'

    # All notifications should have complete sender data
    notifications.each_with_index do |n, i|
      assert n['sender'].present?, "Notification ##{i} missing sender"
      assert n['sender']['login_name'].present?, "Notification ##{i} sender missing login_name"
      assert n['sender']['avatar_url'].present?, "Notification ##{i} sender missing avatar_url"
    end
  end

  test 'notifications with target filter returns only matching kinds' do
    token = create_token('hatsuno', 'testtest')

    Notification::TARGETS_TO_KINDS.each do |target, expected_kinds|
      get api_notifications_path(target:, format: :json),
          headers: { 'Authorization' => "Bearer #{token}" }
      assert_response :ok

      json = JSON.parse(response.body)
      json['notifications'].each do |n|
        assert_includes expected_kinds.map(&:to_s), n['kind'],
                        "target=#{target} returned unexpected kind '#{n['kind']}'"
      end
    end
  end

  test 'notifications with pagination returns correct pages' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(page: 1, per: 5, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    assert json['notifications'].size <= 5, 'Should respect per-page limit'
    assert json['total_pages'].positive?

    # Page 2 should also work
    get api_notifications_path(page: 2, per: 5, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    json2 = JSON.parse(response.body)
    assert_kind_of Array, json2['notifications']

    # Page 1 and 2 should have different notifications (if enough data)
    if json['notifications'].size == 5 && json2['notifications'].size.positive?
      ids1 = json['notifications'].map { |n| n['id'] }
      ids2 = json2['notifications'].map { |n| n['id'] }
      assert_empty ids1 & ids2, 'Page 1 and 2 should not overlap'
    end
  end

  test 'notification sender with company has logo_url and url' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(status: 'unread', format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    with_company = json['notifications'].select { |n| n['sender']['company'].present? }
    assert with_company.size.positive?, 'Should have at least one notification from sender with company'

    with_company.each do |n|
      company = n['sender']['company']
      sender_name = n['sender']['login_name']
      assert company['logo_url'].present?, "#{sender_name}'s company should have logo_url"
      assert company['url'].present?, "#{sender_name}'s company should have url"
      assert_includes company['url'], '/companies/', "#{sender_name}'s company url should be a company path"
    end
  end

  test 'notification sender without company has null company' do
    token = create_token('hatsuno', 'testtest')
    get api_notifications_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    json = JSON.parse(response.body)
    without_company = json['notifications'].select { |n| n['sender']['company'].blank? }

    # We just verify the field exists and is empty/null (not an error)
    without_company.each do |n|
      assert n['sender'].key?('company'), "#{n['sender']['login_name']} should still have company key"
    end
  end

  test 'unauthorized access returns 401' do
    get api_notifications_path(format: :json)
    assert_response :unauthorized

    get api_notifications_path(status: 'unread', format: :json)
    assert_response :unauthorized
  end
end
