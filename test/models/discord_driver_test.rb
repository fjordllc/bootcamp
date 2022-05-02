# frozen_string_literal: true

require 'test_helper'

class DiscordDriverTest < ActiveSupport::TestCase
  test '#call' do
    params = {
      body: 'test message',
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    VCR.use_cassette 'discord/message' do
      assert DiscordDriver.new.call(params)
    end
  end
end
