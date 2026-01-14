# frozen_string_literal: true

require 'test_helper'

class RegularEventTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'regular event update triggers organizer_created notification and enqueues delivery' do
    token = create_token('kimura', 'testtest')
    user = users(:kimura)

    post user_sessions_path, params: {
      authenticity_token: token,
      user: { login: user.login_name, password: 'testtest' }
    }
    follow_redirect!

    regular_event = regular_events(:regular_event4)
    receiver = users(:hatsuno)
    user_ids = %i[kimura hajime hatsuno].map { |organizer_user| users(organizer_user).id.to_s }

    perform_enqueued_jobs do
      patch regular_event_path(regular_event), params: {
        regular_event: {
          user_ids:
        }
      }
    end

    assert_includes regular_event.reload.user_ids, receiver.id
    assert receiver.notifications.reload.where(kind: :create_organizer).exists?
  end
end
