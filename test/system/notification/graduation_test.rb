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

    visit_with_auth user_path(users(:kimura)), 'komagata'
    accept_confirm do
      find('.a-button.is-sm.is-danger.is-block', text: '卒業にする').click
    end
    has_css?('p.flash__message', text: 'ユーザー情報を更新しました。')
    logout

    notifications = Notification.where(user: users(:mentormentaro), kind: Notification.kinds[:graduated])
    assert notifications.any? { |n| n.message.include?('kimuraさんが卒業しました！') }
  end
end
