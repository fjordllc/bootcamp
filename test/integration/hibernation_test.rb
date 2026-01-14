# frozen_string_literal: true

require 'test_helper'

class HibernationTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # modelで分ける
  test 'hibernation triggers organizer_created notification and enqueues delivery' do
    token = create_token('kimura', 'testtest')
    user = users(:kimura)

    post user_sessions_path, params: {
      authenticity_token: token,
      user: { login: user.login_name, password: 'testtest' }
    }
    follow_redirect!

    perform_enqueued_jobs do
      post hibernation_path, params: {
        hibernation: {
          scheduled_return_on: '2026-01-08',
          reason: 'test'
        }
      }
    end

    regular_event = regular_events(:regular_event5)
    receiver = users(:komagata)

    assert_not_includes regular_event.reload.user_ids, user.id
    assert_includes regular_event.user_ids, receiver.id
    assert receiver.notifications.reload.where(kind: :create_organizer).exists?
  end
end
