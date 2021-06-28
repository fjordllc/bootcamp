# frozen_string_literal: true

require 'application_system_test_case'

class Notification::EventsTest < ApplicationSystemTestCase
  test 'waiting user receive notification when the event participant cancel' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    accept_confirm do
      click_link '参加を取り消す'
    end
    sleep 1
    logout

    login_user 'hatsuno', 'testtest'
    open_notification
    assert_equal "#{event.title}で、補欠から参加に繰り上がりました。",
                 notification_message
  end

  test 'waiting user receive notification when the event capacity is increased' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    click_link '内容修正'

    fill_in 'event_capacity', with: 2
    click_button '内容変更'
    logout

    login_user 'hatsuno', 'testtest'
    open_notification
    assert_equal "#{event.title}で、補欠から参加に繰り上がりました。",
                 notification_message
  end
end
