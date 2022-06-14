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
end
