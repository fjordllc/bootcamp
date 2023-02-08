# frozen_string_literal: true

require 'test_helper'

module Discord
  class TimesChannelTest < ActiveSupport::TestCase
    setup do
      @category_id = ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID']
      ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID'] = nil

      @stub_create_text_channel = lambda { |name:, parent:|
        Discordrb::Channel.new({
          id: '1234567890',
          name: name,
          parent_id: parent
        }.stringify_keys, nil)
      }
    end

    teardown do
      ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID'] = @category_id
    end

    test '#save return true' do
      Discord::TimesChannel.category_id = '9876543210'
      Discord::Server.stub(:create_text_channel, @stub_create_text_channel) do
        times_channel = Discord::TimesChannel.new('piyo')

        assert_equal true, times_channel.save
        assert_equal '1234567890', times_channel.id
        assert_equal '9876543210', times_channel.category_id
      end

      Discord::TimesChannel.category_id = nil
      Discord::Server.stub(:create_text_channel, @stub_create_text_channel) do
        times_channel = Discord::TimesChannel.new('piyo')

        assert_equal true, times_channel.save
        assert_equal '1234567890', times_channel.id
        assert_nil times_channel.category_id
      end
    end

    test '#save return false' do
      Discord::Server.stub(:create_text_channel, ->(*) { nil }) do
        times_channel = Discord::TimesChannel.new('piyo')

        assert_equal false, times_channel.save
        assert_nil times_channel.id
        assert_nil times_channel.category_id
      end
    end

    test '.to_channel_name' do
      capitalize = 'Piyo'
      actual = Discord::TimesChannel.to_channel_name(capitalize)
      assert_equal 'piyo', actual

      non_ascii = 'ピヨルド🐥🐤🐣'
      actual = Discord::TimesChannel.to_channel_name(non_ascii)
      assert_equal 'ピヨルド🐥🐤🐣', actual
    end
  end
end
