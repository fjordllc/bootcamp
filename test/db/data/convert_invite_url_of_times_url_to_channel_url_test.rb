# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/data/20210915021559_convert_invite_url_of_times_url_to_channel_url')

class ConvertInviteUrlOfTimesUrlToChannelUrlTest < ActiveSupport::TestCase
  def setup
    @migration = ConvertInviteUrlOfTimesUrlToChannelUrl.new
    @migration.verbose = false
  end

  test '#up' do
    VCR.use_cassette 'discord/invite' do
      # rubocop:disable Rails/SkipsModelValidations
      new_url_user = users(:hatsuno)
      new_url_user.update_attribute(:times_url, 'https://discord.com/channels/715806612824260640/715806613264400385')
      old_url_user1 = users(:komagata)
      old_url_user1.update_attribute(:times_url, 'https://discord.gg/xhGP6etJBX')
      old_url_user2 = users(:kimura)
      old_url_user2.update_attribute(:times_url, 'https://discord.gg/UXUFbKXnXU')
      invalid_old_url_user = users(:yamada)
      invalid_old_url_user.update_attribute(:times_url, 'https://discord.gg/8Px4f7nMUx')
      nil_url_user = users(:hajime)
      nil_url_user.update_attribute(:times_url, nil)
      # rubocop:enable Rails/SkipsModelValidations

      @migration.migrate(:up)

      [new_url_user, old_url_user1, old_url_user2, invalid_old_url_user, nil_url_user].each(&:reload)
      assert_equal 'https://discord.com/channels/715806612824260640/715806613264400385', new_url_user.times_url
      assert_equal 'https://discord.com/channels/715806612824260640/842214030541193247', old_url_user1.times_url
      assert_equal 'https://discord.com/channels/715806612824260640/867709982786191360', old_url_user2.times_url
      assert_nil invalid_old_url_user.times_url
      assert_nil nil_url_user.times_url
    end
  end
end
