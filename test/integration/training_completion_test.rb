# frozen_string_literal: true

require 'test_helper'

class TrainingCompletionTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # modelで分ける
  test 'training complite triggers organizer_created notification and enqueues delivery' do
    token = create_token('kensyu', 'testtest')
    user = users(:kensyu)

    post user_sessions_path, params: {
      authenticity_token: token,
      user: { login: user.login_name, password: 'testtest' }
    }
    follow_redirect!

    perform_enqueued_jobs do
      post training_completion_path, params: {
        user: {
          satisfaction: 'excellent',
          opinion: 'test'
        },
        commit: '研修を終了する'
      }
    end

    receiver = users(:komagata)
    regular_event = regular_events(:regular_event42)

    assert_not_includes regular_event.reload.user_ids, user.id
    assert_includes regular_event.user_ids, receiver.id
    assert receiver.notifications.reload.where(kind: :create_organizer).exists?
  end
end
