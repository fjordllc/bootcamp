# frozen_string_literal: true

require 'application_system_test_case'

class Notification::RegularEventsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
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

    visit_with_auth '/notifications', 'hatsuno'
    within first('.card-list-item.is-unread') do
      assert_text "定期イベント【#{regular_event.title}】が更新されました。"
    end
  end

  test 'notify_coming_soon_regular_events' do
    event_info = <<~TEXT.chomp
      ⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️

      < 今日 (05/05 金) 開催 >

      ⚠️ Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)
      ⚠️ Discord通知確認用、祝日非開催イベント(金曜日開催)
      はお休みです。

      ------------------------------

      < 明日 (05/06 土) 開催 >

      Discord通知確認用イベント(土曜日午前8時から開催)
      時間: 08:00〜09:00
      詳細: <http://localhost:3000/regular_events/507245517>

      Discord通知確認用イベント(土曜日 + 日曜日開催)
      時間: 09:00〜10:00
      詳細: <http://localhost:3000/regular_events/670378901>

      Discord通知確認用イベント(土曜日開催)
      時間: 10:00〜11:00
      詳細: <http://localhost:3000/regular_events/284302086>

      Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)
      時間: 11:00〜12:00
      詳細: <http://localhost:3000/regular_events/808817380>

      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
    TEXT
    params = {
      url: 'https://discord.com/api/webhooks/0123456789/all',
      username: 'ピヨルド',
      avatar_url: 'https://i.gyazo.com/7099977680d8d8c2d72a3f14ddf14cc6.png',
      content: event_info
    }

    stub_message = stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
                   .with(body: params,
                         headers: { 'Content-Type' => 'application/json' })

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
    fill_in 'new_comment[description]', with: '@machida test'
    click_button 'コメントする'
    visit_with_auth '/notifications', 'machida'
    assert_text '定期イベント「開発MTG」へのコメントでkomagataさんからメンションがきました。'
  end
end
