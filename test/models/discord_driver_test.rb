# frozen_string_literal: true

require 'test_helper'

class DiscordDriverTest < ActiveSupport::TestCase
  test '#call' do
    params = {
      body: 'test message',
      name: 'bob',
      webhook_url: 'https://discord.com/api/webhooks/0123456789/xxxxxxxx'
    }

    stub_request(:post, params[:webhook_url]).to_return(status: 204, body: '')

    assert DiscordDriver.new.call(params)
  end
end
