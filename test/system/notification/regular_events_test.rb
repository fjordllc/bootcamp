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

      ⚠️ Discord通知確認用、祝日非開催イベント(金曜日開催)
      ⚠️ Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)
      はお休みです。

      ------------------------------

      < 明日 (05/06 土) 開催 >

      Discord通知確認用イベント(土曜日開催)
      時間: 21:00〜22:00
      詳細: http://localhost:3000/regular_events/284302086

      Discord通知確認用イベント(土曜日 + 日曜日開催)
      時間: 21:00〜22:00
      詳細: http://localhost:3000/regular_events/670378901

      Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)
      時間: 21:00〜22:00
      詳細: http://localhost:3000/regular_events/808817380

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
      visit '/scheduler/daily/notify_coming_soon_regular_events'
    end

    assert_requested(stub_message)
  end

  test 'notify mentor or admin when comment on regular event page' do
    regular_event = regular_events(:regular_event3)
    visit_with_auth "/regular_events/#{regular_event.id}", 'kimura'
    within('.thread-comment-form') do
      fill_in('new_comment[description]', with: 'test')
    end
    click_button 'コメントする'
    assert_text "test"

    visit_with_auth '/notifications', 'komagata'
    within first('.card-list-item.is-unread') do
      assert_text "komagataさんの【「#{regular_event.title}」の定期イベント】にkimuraさんがコメントしました。"
    end
  end
end
