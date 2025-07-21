# frozen_string_literal: true

require 'test_helper'

class TimesChannelCreatorTest < ActiveSupport::TestCase
  test '#call' do
    logs = []
    user = users(:hajime)
    assert user.student?

    Rails.logger.stub(:warn, ->(message) { logs << message }) do
      Discord::TimesChannel.stub(:new, ->(_) { InvalidTimesChannel.new }) do
        TimesChannelCreator.new.call(nil, nil, nil, nil, user:)
      end
      assert_nil user.discord_profile.times_id
      assert_nil user.discord_profile.times_url
      assert_equal "[Discord API] #{user.login_name}の分報チャンネルが作成できませんでした。", logs.pop

      Discord::TimesChannel.stub(:new, ->(_) { ValidTimesChannel.new }) do
        TimesChannelCreator.new.call(nil, nil, nil, nil, user:)
      end
      assert_equal '1234567890123456789', user.discord_profile.times_id
      expected_url = "https://discord.com/channels/#{ENV['DISCORD_GUILD_ID']}/1234567890123456789"
      assert_equal expected_url, user.discord_profile.times_url
      assert_nil logs.last
    end
  end

  test '#call with role' do
    user = users(:adminonly)
    assert user.admin?
    assert_raise ArgumentError do
      TimesChannelCreator.new.call(nil, nil, nil, nil, user:)
    end
    assert_not user.student_or_trainee?

    user = users(:mentormentaro)
    assert user.mentor?
    assert_raise ArgumentError do
      TimesChannelCreator.new.call(nil, nil, nil, nil, user:)
    end
    assert_not user.student_or_trainee?

    user = users(:senpai)
    assert user.adviser?
    assert_raise ArgumentError do
      TimesChannelCreator.new.call(nil, nil, nil, nil, user:)
    end
    assert_not user.student_or_trainee?
  end

  class ValidTimesChannel
    def save
      true
    end

    def id
      '1234567890123456789'
    end
  end

  class InvalidTimesChannel
    def save
      false
    end
  end
end
