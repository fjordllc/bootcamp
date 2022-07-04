# frozen_string_literal: true

require 'application_system_test_case'

class Notification::GraduationTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify mentor when student graduate' do
    users(:kimura).update!(last_activity_at: Time.current)
    # kimura が一番上に表示されるようにソート
    path = 'admin/users?direction=desc&order_by=last_activity_at&target=student_and_trainee'
    visit_with_auth path, 'komagata'

    accept_confirm do
      first('.a-button.is-sm.is-primary', text: '卒業').click
    end
    logout

    visit_with_auth '/notifications', 'mentormentaro'
    within first('.card-list-item.is-unread') do
      assert_text '🎉️ ️️kimuraさんが卒業しました！'
    end
  end
end
