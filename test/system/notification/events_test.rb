# frozen_string_literal: true

require 'application_system_test_case'

class Notification::EventsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'waiting user receive notification when the event participant cancel' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    accept_confirm do
      click_link '参加を取り消す'
    end
    assert_text '参加を取り消しました。'

    notifications = Notification.where(user: users(:hatsuno), kind: Notification.kinds[:moved_up_event_waiting_user])
    assert notifications.any? { |n| n.message.include?("#{event.title}で、補欠から参加に繰り上がりました。") }
  end

  test 'waiting user receive notification when the event capacity is increased' do
    event = events(:event3)
    visit_with_auth event_path(event), 'komagata'
    click_link '内容修正'

    fill_in 'event_capacity', with: 2
    click_button '内容を更新'
    assert_text 'イベントを更新しました。'

    notifications = Notification.where(user: users(:hatsuno), kind: Notification.kinds[:moved_up_event_waiting_user])
    assert notifications.any? { |n| n.message.include?("#{event.title}で、補欠から参加に繰り上がりました。") }
  end
end
