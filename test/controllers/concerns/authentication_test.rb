# frozen_string_literal: true

require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test 'records the last activity time of a logged-in user on each request' do
    user = users(:kimura)
    sign_in user

    travel_to Time.zone.local(2030, 1, 2, 3, 4, 5) do
      get edit_current_user_path
    end

    assert_response :success
    assert_equal Time.zone.local(2030, 1, 2, 3, 4, 5), user.reload.last_activity_at
  end

  test 'completes the request when the database connection drops while recording the last activity time' do
    user = users(:kimura)
    sign_in user
    recorded_at = user.reload.last_activity_at
    warnings = []
    connection_dropped = ->(*) { raise ActiveRecord::ConnectionFailed, 'server closed the connection unexpectedly' }

    Rails.logger.stub(:warn, ->(*arguments) { warnings << arguments.first if arguments.any? }) do
      User.stub_any_instance(:set_last_activity_at, connection_dropped) do
        patch current_user_path, params: { user: { description: '接続が切れても更新できます。' } }
      end
    end

    assert_redirected_to user_path(user)
    assert_equal '接続が切れても更新できます。', user.reload.description
    assert_equal recorded_at, user.last_activity_at
    expected_warning = {
      'event' => 'last_activity_time_not_registered',
      'error_class' => 'ActiveRecord::ConnectionFailed',
      'request_id' => response.headers['X-Request-Id']
    }
    assert_equal expected_warning, JSON.parse(warnings.grep(/last_activity_time_not_registered/).sole)
  end

  test 'does not hide other failures while recording the last activity time' do
    sign_in users(:kimura)

    [ActiveRecord::StatementInvalid, NoMethodError].each do |error_class|
      assert_raises(error_class) do
        User.stub_any_instance(:set_last_activity_at, ->(*) { raise error_class, 'unexpected failure' }) do
          get root_path
        end
      end
    end
  end
end
