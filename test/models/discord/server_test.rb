# frozen_string_literal: true

require 'test_helper'

module Discord
  class ServerTest < ActiveSupport::TestCase
    setup do
      @guild_id = Discord::Server.guild_id
      @bot_token = Discord::Server.authorize_token

      Discord::Server.guild_id = '1234567890123456789'
      Discord::Server.authorize_token = 'Bot valid token'
    end

    teardown do
      Discord::Server.guild_id = @guild_id
      Discord::Server.authorize_token = @bot_token
    end

    test '.find_by' do
      logs = []
      Rails.logger.stub(:error, ->(message) { logs << message }) do
        VCR.use_cassette 'discord/server/find_by' do
          actual = Discord::Server.find_by(id: '1234567890123456789', token: 'Bot valid token')
          assert_kind_of Discordrb::Server, actual
          assert_nil logs.last
        end

        VCR.use_cassette 'discord/server/find_by_with_unauthorized' do
          actual = Discord::Server.find_by(id: '1234567890123456789', token: 'Bot invalid token')
          assert_nil actual
          assert_equal '[Discord API] 401: Unauthorized', logs.pop
        end

        Discord::Server.stub(:enabled?, -> { false }) do
          actual = Discord::Server.find_by(id: '1234567890123456789', token: 'Bot valid token')
          assert_nil actual
          assert_nil logs.last
        end
      end
    end

    test '.create_text_channel return Discordrb::Channel' do
      VCR.use_cassette 'discord/server/create_text_channel_without_parent' do
        actual = Discord::Server.create_text_channel(name: 'wakaran🔰')

        assert_kind_of Discordrb::Channel, actual
        assert_equal 'wakaran🔰', actual.name
        assert_not_nil actual.id
        assert_nil actual.parent_id
      end

      VCR.use_cassette 'discord/server/create_text_channel_with_parent' do
        actual = Discord::Server.create_text_channel(name: 'wakaran🔰', parent: '1069968944359813131')

        assert_kind_of Discordrb::Channel, actual
        assert_equal 'wakaran🔰', actual.name
        assert_not_nil actual.id
        assert_not_nil actual.parent_id
      end
    end

    test '#create_text_channel return nil by error' do
      logs = []
      Rails.logger.stub(:error, ->(message) { logs << message }) do
        VCR.use_cassette 'discord/server/create_text_channel_without_name' do
          actual = Discord::Server.create_text_channel(name: nil)
          assert_nil actual
          assert_match(/\[Discord API\] (.+)+ name: This field is required/m, logs.pop)
        end

        VCR.use_cassette 'discord/server/create_text_channel_with_invalid_parent' do
          actual = Discord::Server.create_text_channel(name: 'wakaran🔰', parent: 'invalid parent')
          assert_nil actual
          assert_match(/\[Discord API\] (.+) parent_id: Category does not exist/m, logs.pop)
        end

        VCR.use_cassette 'discord/server/create_text_channel_with_max_channels_by_category' do
          actual = Discord::Server.create_text_channel(name: 'wakaran🔰', parent: '1069968944359813131')
          assert_nil actual
          assert_match(/\[Discord API\] (.+) parent_id: Maximum number of channels in category reached \(50\)/m, logs.pop)
        end

        VCR.use_cassette 'discord/server/create_text_channel_with_max_channels_by_server' do
          actual = Discord::Server.create_text_channel(name: 'wakaran🔰')
          assert_nil actual
          assert_equal '[Discord API] Maximum number of server channels reached (500)', logs.pop
        end

        VCR.use_cassette 'discord/server/create_text_channel_with_unauthorized' do
          Discord::Server.authorize_token = 'Bot invalid token'
          actual = Discord::Server.create_text_channel(name: 'wakaran🔰')
          assert_nil actual
          assert_equal '[Discord API] 401: Unauthorized', logs.pop
        end
      end
    end

    test '.enabled?' do
      Discord::Server.guild_id = '1234567890123456789'
      Discord::Server.authorize_token = 'Bot valid token'
      ENV['DISCORD_GUILD_ID'] = nil
      ENV['DISCORD_BOT_TOKEN'] = nil
      assert Discord::Server.enabled?

      Discord::Server.guild_id = nil
      Discord::Server.authorize_token = nil
      ENV['DISCORD_GUILD_ID'] = '1234567890123456789'
      ENV['DISCORD_BOT_TOKEN'] = 'Bot valid token'
      assert Discord::Server.enabled?

      Discord::Server.guild_id = nil
      Discord::Server.authorize_token = nil
      ENV['DISCORD_GUILD_ID'] = nil
      ENV['DISCORD_BOT_TOKEN'] = nil
      assert_not Discord::Server.enabled?

      Discord::Server.guild_id = nil
      Discord::Server.authorize_token = 'skip'
      ENV['DISCORD_GUILD_ID'] = nil
      ENV['DISCORD_BOT_TOKEN'] = nil
      assert_not Discord::Server.enabled?
    end
  end
end
