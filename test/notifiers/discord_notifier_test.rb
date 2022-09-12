# frozen_string_literal: true

require 'test_helper'

class DiscordNotifierTest < ActiveSupport::TestCase
  include AbstractNotifier::TestHelper

  setup do
    AbstractNotifier::Testing::Driver.clear
  end

  teardown do
    AbstractNotifier::Testing::Driver.clear
  end

  test '.graduated' do
    params = {
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    expected = {
      body: 'kimuraさんが卒業しました。',
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_notifications_sent 2, **expected do
      DiscordNotifier.graduated(params).notify_now
      DiscordNotifier.with(params).graduated.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.graduated(params).notify_later
      DiscordNotifier.with(params).graduated.notify_later
    end
  end

  test '.post_announcement' do
    params = {
      body: 'test message',
      announce: announcements(:announcement1),
      name: 'bob'
    }

    expected = {
      body: "お知らせ：「お知らせ1」\rhttps://bootcamp.fjord.jp/announcements/395315747",
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_notifications_sent 2, **expected do
      DiscordNotifier.post_announcement(params).notify_now
      DiscordNotifier.with(params).post_announcement.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.post_announcement(params).notify_later
      DiscordNotifier.with(params).post_announcement.notify_later
    end
  end

  test '.tomorrow_regular_event' do
    params = {
      event: regular_events(:regular_event1),
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    expected = {
      body: "⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️
      【イベントのお知らせ】
      明日 07月31日（日）に開催されるイベントです！
      --------------------------------------------
      開発MTG
      時間: 15:00 〜 16:00
      詳細: http://localhost:3000/regular_events/459650222
      --------------------------------------------\n⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️",
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    travel_to Time.zone.local(2022, 7, 30, 0, 0, 0) do
      assert_notifications_sent 2, **expected do
        DiscordNotifier.tomorrow_regular_event(params).notify_now
        DiscordNotifier.with(params).tomorrow_regular_event.notify_now
      end
    end
  end

  test '.invaid_user' do
    params = {
      body: 'test message',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_notifications_sent 2, **params do
      DiscordNotifier.invalid_user(params).notify_now
      DiscordNotifier.with(params).invalid_user.notify_now
    end

    assert_notifications_enqueued 2, **params do
      DiscordNotifier.invalid_user(params).notify_later
      DiscordNotifier.with(params).invalid_user.notify_later
    end
  end
end
