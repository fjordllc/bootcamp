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

  test 'notify_coming_soon_regular_events' do
    stub_message = stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
                   .with(headers: { 'Content-Type' => 'application/json' }) do |request|
      body = JSON.parse(request.body)
      body['username'] == 'ピヨルド' &&
        body['content'].include?('⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️') &&
        body['content'].include?('< 今日 (05/05 金) 開催 >') &&
        body['content'].include?('< 明日 (05/06 土) 開催 >') &&
        body['content'].include?('Discord通知確認用イベント(土曜日午前8時から開催)') &&
        body['content'].include?('Discord通知確認用イベント(土曜日 + 日曜日開催)') &&
        body['content'].include?('Discord通知確認用イベント(土曜日開催)') &&
        body['content'].include?('Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)')
    end

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_notify_coming_soon_regular_events_path(token: 'token')
      end
    end

    assert_requested(stub_message)
  end

  test 'notify correct message when mentioned' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'komagata'
    within('.thread-comment-form__form') do
      fill_in 'new_comment[description]', with: '@machida test'
    end
    click_button 'コメントする'
    assert_text '@machida test'
    assert_user_has_notification(user: users(:machida), kind: Notification.kinds[:mentioned], text: '定期イベント「開発MTG」へのコメントでkomagataさんからメンションがきました。')
  end
end
