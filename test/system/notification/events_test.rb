# frozen_string_literal: true

require 'application_system_test_case'

class Notification::EventsTest < ApplicationSystemTestCase
  test 'waiting user receive notification when the event participant cancel' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    accept_confirm do
      click_link '参加を取り消す'
    end

    visit_with_auth '/notifications', 'hatsuno'

    within first('.thread-list-item.is-unread') do
      assert_text "#{event.title}で、補欠から参加に繰り上がりました。"
    end
  end

  test 'waiting user receive notification when the event capacity is increased' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    click_link '内容修正'

    fill_in 'event_capacity', with: 2
    click_button '内容変更'

    visit_with_auth '/notifications', 'hatsuno'

    within first('.thread-list-item.is-unread') do
      assert_text "#{event.title}で、補欠から参加に繰り上がりました。"
    end
  end
end
