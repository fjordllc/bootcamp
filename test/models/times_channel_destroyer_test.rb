# frozen_string_literal: true

require 'test_helper'

class TimesChannelDestroyerTest < ActiveSupport::TestCase
  test '#call' do
    logs = []
    user = users(:hajime)
    user.discord_profile.times_id = '987654321987654321'
    user.discord_profile.account_name = 'hajime#1234'
    user.save!(validate: false)

    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::Server.stub(:delete_text_channel, true) do
        TimesChannelDestroyer.new.call(nil, nil, nil, nil, { user: })
      end
      assert_nil user.discord_profile.times_id
      assert_nil user.discord_profile.times_url
      assert_nil logs.last
    end
  end

  test '#call preserves persisted channel information when deletion is forbidden' do
    logs = []
    user = users(:hajime)
    times_id = '987654321987654321'
    times_url = "https://discord.com/channels/1234567890123456789/#{times_id}"
    user.discord_profile.update!(times_id:, times_url:)

    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::Server.stub(:authorize_token, 'Bot valid token') do
        VCR.use_cassette 'discord/server/delete_text_channel_with_missing_permissions' do
          TimesChannelDestroyer.new.call(nil, nil, nil, nil, { user: })
        end
      end
    end

    assert_equal times_id, user.discord_profile.reload.times_id
    assert_equal times_url, user.discord_profile.times_url
    assert_equal "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。", logs.last
  end

  test '#call with failure' do
    logs = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321')
    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::Server.stub(:delete_text_channel, nil) do
        TimesChannelDestroyer.new.call(nil, nil, nil, nil, { user: })
      end
      assert_equal '987654321987654321', user.discord_profile.times_id
      assert_equal "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。", logs.last
    end
  end
end
