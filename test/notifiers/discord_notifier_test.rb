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
      body: "お知らせ：「お知らせ1」\rhttps://bootcamp.fjord.jp/announcements/395315747",
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

  test '.tomorrow_regular_event' do
    params = {
      event: regular_events(:regular_event1),
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }
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

    expected = {
      body: event_info,
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
    ⚠️ kimuraさんの「PC性能の見方を知る」の提出物が、最後のコメントから5日経過しました。
    担当：komagataさん
    URL： http://localhost:3000/products/313836099
    TEXT

    params = {
      comment: comment,
      body: body,
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    expected = {
      body: body,
      name: 'ピヨルド',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }
    assert_notifications_sent 2, **expected do
      DiscordNotifier.product_review_not_completed(params).notify_now
      DiscordNotifier.with(params).product_review_not_completed.notify_now
    end

    assert_notifications_enqueued 2, **expected do
      DiscordNotifier.product_review_not_completed(params).notify_later
      DiscordNotifier.with(params).product_review_not_completed.notify_later
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
      URL： http://localhost:3000/reports/819157022
    TEXT
    expected = {
      body: body,
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
