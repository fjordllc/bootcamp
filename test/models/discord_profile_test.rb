# frozen_string_literal: true

require 'test_helper'

class DiscordProfileTest < ActiveSupport::TestCase
  test 'account_name' do
    discord_profile = discord_profiles(:discord_profile_komagata)
    discord_profile.account_name = ''
    assert discord_profile.valid?
    discord_profile.account_name = 'komagata1234'
    assert discord_profile.valid?
    discord_profile.account_name = 'komagata..'
    assert discord_profile.invalid?
    discord_profile.account_name = '#1234'
    assert discord_profile.invalid?
    discord_profile.account_name = ' komagata　#1234'
    assert discord_profile.invalid?
    discord_profile.account_name = 'komagata-1234'
    assert discord_profile.invalid?
  end

  test 'times_url' do
    discord_profile = discord_profiles(:discord_profile_komagata)
    discord_profile.times_url = ''
    assert discord_profile.valid?
    discord_profile.times_url = 'https://discord.com/channels/715806612824260640/123456789000000001'
    assert discord_profile.valid?
    discord_profile.times_url = "https://discord.com/channels/715806612824260640/12345678900000000\n"
    assert discord_profile.invalid?
    discord_profile.times_url = 'https://discord.com/channels/715806612824260640/123456789000000001/123456789000000001'
    assert discord_profile.invalid?
    discord_profile.times_url = 'https://discord.gg/jc9fnWk4'
    assert discord_profile.invalid?
    discord_profile.times_url = 'https://example.com/channels/715806612824260640/123456789000000001'
    assert discord_profile.invalid?
  end
end
