# frozen_string_literal: true

require 'test_helper'

class DiscordMemberTest < ActiveSupport::TestCase
  setup do
    @guild_id = ENV['DISCORD_GUILD_ID']
    @bot_token = ENV['DISCORD_BOT_TOKEN']

    ENV['DISCORD_GUILD_ID'] = '0123456789'
    ENV['DISCORD_BOT_TOKEN'] = 'example'
  end

  teardown do
    ENV['DISCORD_GUILD_ID'] = @guild_id
    ENV['DISCORD_BOT_TOKEN'] = @bot_token
  end

  test '.find_by return found' do
    VCR.use_cassette 'discord/guild_members/found_human' do
      found = DiscordMember.find_by(account_name: 'Human#4545')
      assert_equal found.account_name, 'Human#4545'
    end

    VCR.use_cassette 'discord/guild_members/found_human_with_kanji' do
      found = DiscordMember.find_by(account_name: 'ひらがなと漢字#0019')
      assert_equal found.account_name, 'ひらがなと漢字#0019'
    end

    VCR.use_cassette 'discord/guild_members/found_bot' do
      found = DiscordMember.find_by(account_name: 'TestBot ✨#5803')
      assert_equal found.account_name, 'TestBot ✨#5803'
    end
  end

  test '.find_by return nil by unauthorized' do
    ENV['DISCORD_BOT_TOKEN'] = 'unauthorized'
    VCR.use_cassette 'discord/guild_members/unauthorized_get' do
      found = DiscordMember.find_by(account_name: 'Human#4545')
      assert_nil found
    end
  end

  test '.find_by return nil by not found with blank name' do
    found = DiscordMember.find_by(account_name: '')
    assert_nil found
  end

  test '.find_by return nil by not found' do
    VCR.use_cassette 'discord/guild_members/not_found' do
      found = DiscordMember.find_by(account_name: 'Unknown')
      assert_nil found
    end
  end

  test '.find_by return nil by not found with unsafe name' do
    VCR.use_cassette 'discord/guild_members/not_found_with_unsafe_name' do
      found = DiscordMember.find_by(account_name: '^#\#0019')
      assert_nil found
    end
  end

  test '.find_by return nil by server error' do
    logs = []
    stub_error_logger = ->(message) { logs << message }
    Rails.logger.stub(:error, stub_error_logger) do
      stub_timeout_error = ->(_path) { raise Net::OpenTimeout }
      Discord::Resource.stub(:get, stub_timeout_error) do
        found = DiscordMember.find_by(account_name: 'Human#4545')
        assert_nil found
      end
    end
    assert_match '[Discord API] APIへの接続がタイムアウトしました。', logs.to_s
  end

  test '#destroy return true by destroyed' do
    VCR.use_cassette 'discord/guild_members/found_human' do
      @discord_member = DiscordMember.find_by(account_name: 'Human#4545')
    end

    VCR.use_cassette 'discord/guild_members/kick_human' do
      assert @discord_member.destroy
    end
  end

  test '#destroy return false by unknown user' do
    # NOTE: https://discord.com/developers/docs/topics/opcodes-and-status-codes#:~:text=lack%20permissions
    VCR.use_cassette 'discord/guild_members/kick_unknown_user' do
      discord_member = DiscordMember.new(user: { bot: false, id: 654_321, username: 'Unknown' }, roles: [])
      assert_not discord_member.destroy
    end
  end

  test '#destroy return false by bot' do
    discord_member = DiscordMember.new(user: { bot: true, id: 123_456 }, roles: [])
    assert_not discord_member.destroy
  end

  test '#destroy return false by has role' do
    discord_member = DiscordMember.new(user: { bot: false, id: 123_456 }, roles: ['87654321'])
    assert_not discord_member.destroy
  end

  test '#destroy return false by unauthorized' do
    ENV['DISCORD_BOT_TOKEN'] = 'unauthorized'
    VCR.use_cassette 'discord/guild_members/unauthorized_delete' do
      discord_member = DiscordMember.new(user: { bot: false, id: 123_456 }, roles: [])
      assert_not discord_member.destroy
    end
  end

  test '#destroy return false by lack permission' do
    ENV['DISCORD_BOT_TOKEN'] = 'NOT PRIVILEGED GATEWAY FOR GUILD MEMBERS INTENT'
    # NOTE: https://discord.com/developers/docs/topics/opcodes-and-status-codes#:~:text=lack%20permissions
    VCR.use_cassette 'discord/guild_members/kick_with_lack_permission' do
      discord_member = DiscordMember.new(user: { bot: false, id: 123_456 }, roles: [])
      assert_not discord_member.destroy
    end
  end

  test '#destroy return false by try to kick owner' do
    VCR.use_cassette 'discord/guild_members/found_human_with_owner' do
      @discord_member = DiscordMember.find_by(account_name: 'オーナーだがロールなし#8181')
    end
    # NOTE: https://discord.com/developers/docs/topics/opcodes-and-status-codes#:~:text=Missing%20access
    VCR.use_cassette 'discord/guild_members/kick_with_missing_access' do
      assert_not @discord_member.destroy
    end
  end

  test '#destroy return false by server error' do
    logs = []
    stub_error_logger = ->(message) { logs << message }
    Rails.logger.stub(:error, stub_error_logger) do
      stub_timeout_error = ->(_path) { raise Net::OpenTimeout }
      Discord::Resource.stub(:delete, stub_timeout_error) do
        discord_member = DiscordMember.new(user: { bot: false, id: 123_456 }, roles: [])
        assert_not discord_member.destroy
      end
    end
    assert_match '[Discord API] APIへの接続がタイムアウトしました。', logs.to_s
  end
end
