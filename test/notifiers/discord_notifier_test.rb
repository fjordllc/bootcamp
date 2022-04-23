# frozen_string_literal: true

require 'test_helper'

class DiscordNotifierTest < ActiveSupport::TestCase
  setup do
    @params = {
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }
  end

  test '.graduated' do
    notification = DiscordNotifier.graduated(@params)

    assert_difference -> { AbstractNotifier::Testing::Driver.deliveries.count }, 1 do
      notification.notify_now
    end

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, 1 do
      notification.notify_later
    end
  end
end
