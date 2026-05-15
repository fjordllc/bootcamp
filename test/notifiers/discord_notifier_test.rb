# frozen_string_literal: true

require 'test_helper'

class DiscordNotifierTest < ActiveSupport::TestCase
  test '.graduated' do
    params = {
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.graduated(params).notify_now
      DiscordNotifier.with(params).graduated.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
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

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.announced(params).notify_now
      DiscordNotifier.with(params).announced.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
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

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
        DiscordNotifier.with(params).coming_soon_regular_events.notify_now
        DiscordNotifier.coming_soon_regular_events(params).notify_now
      end
    end

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
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

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.invalid_user(params).notify_now
      DiscordNotifier.with(params).invalid_user.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      DiscordNotifier.invalid_user(params).notify_later
      DiscordNotifier.with(params).invalid_user.notify_later
    end
  end

  test '.payment_failed' do
    params = {
      body: 'test message'
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.payment_failed(params).notify_now
      DiscordNotifier.with(params).payment_failed.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      DiscordNotifier.payment_failed(params).notify_later
      DiscordNotifier.with(params).payment_failed.notify_later
    end
  end

  test '.product_review_not_completed' do
    products(:product8).update!(checker_id: users(:komagata).id)
    comment = Comment.create!(user: users(:kimura), commentable: products(:product8), description: '提出者による返信')

    params = {
      comment:,
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    Discord::Server.stub(:find_member_id, '12345') do
      assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
        DiscordNotifier.product_review_not_completed(params).notify_now
        DiscordNotifier.with(params).product_review_not_completed.notify_now
      end

      assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
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

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.hibernated(params).notify_now
      DiscordNotifier.with(params).hibernated.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      DiscordNotifier.hibernated(params).notify_later
      DiscordNotifier.with(params).hibernated.notify_later
    end
  end

  test '.first_report' do
    params = {
      report: reports(:report10),
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 2 do
      DiscordNotifier.first_report(params).notify_now
      DiscordNotifier.with(params).first_report.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 2 do
      DiscordNotifier.first_report(params).notify_later
      DiscordNotifier.with(params).first_report.notify_later
    end
  end
end
