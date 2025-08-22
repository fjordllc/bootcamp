# frozen_string_literal: true

require 'application_system_test_case'

class Notification::UnconfirmedLinksOpenTest < ApplicationSystemTestCase
  driven_by :rack_test

  setup do
    @mentor = users(:komagata)
    @student = users(:kimura)
  end

  test 'mentor sees bulk open button when unread notifications exist' do
    visit_with_auth notifications_path(status: :unread), 'komagata'
    assert_selector 'button', text: '未読の通知を一括で開く'
  end

  test 'mentor does not see bulk open button when no unread notifications exist' do
    Notification.where(user: @mentor).update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

    visit_with_auth notifications_path(status: :unread), 'komagata'
    assert_no_selector 'button', text: '未読の通知を一括で開く'
  end

  test 'non-mentor never sees bulk open button' do
    visit_with_auth notifications_path(status: :unread), 'kimura'
    assert_no_selector 'button', text: '未読の通知を一括で開く'
  end
end
