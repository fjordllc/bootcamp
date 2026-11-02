# frozen_string_literal: true

require 'test_helper'

class TimesChannelDestroyerTest < ActiveSupport::TestCase
  test '#call' do
    logs = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321', times_url: 'https://discord.com/channels/123/987654321987654321')
    user.discord_profile.account_name = 'hajime#1234'
    user.save!(validate: false)

    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::Server.stub(:delete_text_channel, true) do
        TimesChannelDestroyer.new.call('retirement.create', nil, nil, nil, { user: })
      end
      assert_nil user.discord_profile.reload.times_id
      assert_nil user.discord_profile.times_url
      assert_nil logs.last
    end
  end

  test '#call reports forbidden retirement deletion once and preserves persisted channel information' do
    reports = []
    user = users(:hajime)
    times_id = '987654321987654321'
    times_url = "https://discord.com/channels/1234567890123456789/#{times_id}"
    user.discord_profile.update!(times_id:, times_url:)

    Rollbar.stub(:error, ->(*args) { reports << args }) do
      Discord::Server.stub(:authorize_token, 'Bot valid token') do
        VCR.use_cassette 'discord/server/delete_text_channel_with_missing_permissions' do
          TimesChannelDestroyer.new.call('retirement.create', nil, nil, nil, { user: })
        end
      end
    end

    assert_equal times_id, user.discord_profile.reload.times_id
    assert_equal times_url, user.discord_profile.times_url
    assert_equal 1, reports.size
    error, context = reports.first
    assert_instance_of Discordrb::Errors::NoPermission, error
    assert_equal 'retirement.create', context[:event]
    assert_equal user.id, context[:user_id]
    assert_equal times_id, context[:channel_id]
    assert_equal 'botの権限を修正し、残存チャンネルを削除してください。両方の対応が完了してからRollbarを解決済みにしてください。', context[:recovery_action]
  end

  test '#call propagates forbidden graduation deletion without reporting' do
    reports = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321')

    Rollbar.stub(:error, ->(*args) { reports << args }) do
      Discord::Server.stub(:authorize_token, 'Bot valid token') do
        VCR.use_cassette 'discord/server/delete_text_channel_with_missing_permissions' do
          assert_raises(Discordrb::Errors::NoPermission) do
            TimesChannelDestroyer.new.call('training_completion.create', nil, nil, nil, { user: })
          end
        end
      end
    end

    assert_empty reports
    assert_equal '987654321987654321', user.discord_profile.reload.times_id
  end

  test '#call propagates unexpected deletion errors without reporting' do
    reports = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321')
    error = RuntimeError.new('unexpected error')

    Rollbar.stub(:error, ->(*args) { reports << args }) do
      Discord::Server.stub(:delete_text_channel, ->(*) { raise error }) do
        actual = assert_raises(RuntimeError) do
          TimesChannelDestroyer.new.call('retirement.create', nil, nil, nil, { user: })
        end
        assert_same error, actual
      end
    end

    assert_empty reports
    assert_equal '987654321987654321', user.discord_profile.reload.times_id
  end

  test '#call does not handle permission errors from saving the profile' do
    reports = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321')

    Rollbar.stub(:error, ->(*args) { reports << args }) do
      Discord::Server.stub(:delete_text_channel, true) do
        user.discord_profile.stub(:save!, ->(*) { raise Discordrb::Errors::NoPermission }) do
          assert_raises(Discordrb::Errors::NoPermission) do
            TimesChannelDestroyer.new.call('retirement.create', nil, nil, nil, { user: })
          end
        end
      end
    end

    assert_empty reports
  end

  test '#call with failure' do
    logs = []
    user = users(:hajime)
    user.discord_profile.update!(times_id: '987654321987654321')
    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::Server.stub(:delete_text_channel, nil) do
        TimesChannelDestroyer.new.call('retirement.create', nil, nil, nil, { user: })
      end
      assert_equal '987654321987654321', user.discord_profile.times_id
      assert_equal "[Discord API] #{user.login_name}の分報チャンネルが削除できませんでした。", logs.last
    end
  end
end
