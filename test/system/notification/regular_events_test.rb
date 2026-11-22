# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::RegularEventsTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 開催が近い定期イベントの Discord 通知は
  # test/controllers/scheduler/daily/notify_coming_soon_regular_events_controller_test.rb で確かめる。
  test 'notify when a regular event change' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth "/regular_events/#{regular_event.id}/edit", 'komagata'
    within('form[name=regular_event]') do
      fill_in('regular_event[description]', with: 'updated')
    end
    click_button '内容変更'
    assert_text '定期イベントを更新しました。'

    assert_user_has_notification(user: users(:hatsuno), kind: Notification.kinds[:regular_event_updated], text: "定期イベント【#{regular_event.title}】が更新されました。")
  end

  test 'notify correct message when mentioned' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'komagata'
    within('.thread-comment-form__form') do
      fill_in 'comment[description]', with: '@machida test'
    end
    click_button 'コメントする'
    assert_text '@machida test'
    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:mentioned], text: '定期イベント「開発MTG」へのコメントでkomagataさんからメンションがきました。')
  end
end
