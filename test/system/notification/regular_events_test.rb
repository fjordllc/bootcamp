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

  test 'notify_tommorrow_regular_event' do
    event_info = <<~TEXT.chomp
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
      【イベントのお知らせ】
      明日 07月31日（日）に開催されるイベントです！
      --------------------------------------------
      開発MTG
      時間: 15:00 〜 16:00
      詳細: http://localhost:3000/regular_events/459650222
      --------------------------------------------
      ⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
    TEXT
    params = {
      url: 'https://discord.com/api/webhooks/0123456789/admin',
      username: 'ピヨルド',
      avatar_url: 'https://i.gyazo.com/7099977680d8d8c2d72a3f14ddf14cc6.png',
      content: event_info
    }

    stub_message = stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
                   .with(body: params,
                         headers: { 'Content-Type' => 'application/json' })

    travel_to Time.zone.local(2022, 7, 30, 0, 0, 0) do
      visit_with_auth '/scheduler/daily/notify_tomorrow_regular_event', 'komagata'
    end

    assert_requested(stub_message)
  end
end
