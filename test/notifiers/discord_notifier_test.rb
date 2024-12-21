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

  test '.announced' do
    params = {
      body: 'test message',
      announce: announcements(:announcement1),
      name: 'bob'
    }

    expected = {
      body: "お知らせ：「お知らせ1」\r<https://bootcamp.fjord.jp/announcements/395315747>",
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/all'
    }

    assert_notifications_sent 2, **expected do
      DiscordNotifier.announced(params).notify_now
      DiscordNotifier.with(params).announced.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.announced(params).notify_later
      DiscordNotifier.with(params).announced.notify_later
    end
  end

  test '.coming_soon_regular_events' do
    params = {
      today_events: [regular_events(:regular_event26), regular_events(:regular_event30), regular_events(:regular_event31)],
      tomorrow_events: [regular_events(:regular_event28), regular_events(:regular_event29), regular_events(:regular_event31), regular_events(:regular_event33)],
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }
    event_info = <<~TEXT.chomp
      ⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️

      < 今日 (05/05 金) 開催 >

      ダッシュボード表示確認用テスト定期イベント
      時間: 21:00〜22:00
      詳細: <http://localhost:3000/regular_events/927610372>

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

    expected = {
      body: event_info,
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      assert_notifications_sent 2, **expected do
        DiscordNotifier.with(params).coming_soon_regular_events.notify_now
        DiscordNotifier.coming_soon_regular_events(params).notify_now
      end
    end

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      assert_notifications_enqueued 2, **expected do
        DiscordNotifier.with(params).coming_soon_regular_events.notify_later
        DiscordNotifier.coming_soon_regular_events(params).notify_later
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

  test '.payment_failed' do
    params = {
      body: 'test message'
    }

    assert_notifications_sent 2, **params do
      DiscordNotifier.payment_failed(params).notify_now
      DiscordNotifier.with(params).payment_failed.notify_now
    end

    assert_notifications_enqueued 2, **params do
      DiscordNotifier.payment_failed(params).notify_later
      DiscordNotifier.with(params).payment_failed.notify_later
    end
  end

  test '.product_review_not_completed' do
    products(:product8).update!(checker_id: users(:komagata).id)
    comment = Comment.create!(user: users(:kimura), commentable: products(:product8), description: '提出者による返信')
    body = <<~TEXT.chomp
      ⚠️ kimuraさんの「PC性能の見方を知る」の提出物が、最後のコメントから3日経過しました。
      担当：<@12345>さん
      URL： <http://localhost:3000/products/313836099>
    TEXT

    params = {
      comment:,
      body:,
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    expected = {
      body:,
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    Discord::Server.stub(:find_member_id, '12345') do
      assert_notifications_sent 2, **expected do
        DiscordNotifier.product_review_not_completed(params).notify_now
        DiscordNotifier.with(params).product_review_not_completed.notify_now
      end

      assert_notifications_enqueued 2, **expected do
        DiscordNotifier.product_review_not_completed(params).notify_later
        DiscordNotifier.with(params).product_review_not_completed.notify_later
      end
    end
  end

  test '.hibernated' do
    params = {
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    expected = {
      body: 'kimuraさんが休会しました。',
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_notifications_sent 2, **expected do
      DiscordNotifier.hibernated(params).notify_now
      DiscordNotifier.with(params).hibernated.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.hibernated(params).notify_later
      DiscordNotifier.with(params).hibernated.notify_later
    end
  end

  test '.first_report' do
    params = {
      report: reports(:report10),
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    body = <<~TEXT.chomp
      🎉 hajimeさんがはじめての日報を書きました！
      タイトル：「初日報です」
      URL： <http://localhost:3000/reports/819157022>
    TEXT
    expected = {
      body:,
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_notifications_sent 2, **expected do
      DiscordNotifier.first_report(params).notify_now
      DiscordNotifier.with(params).first_report.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.first_report(params).notify_later
      DiscordNotifier.with(params).first_report.notify_later
    end
  end
end
