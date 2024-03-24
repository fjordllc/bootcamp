# frozen_string_literal: true

require 'test_helper'

class DiscordAuthenticationTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test '引数が正常な値の時' do
    user = users(:komagata)
    discord_authentication = DiscordAuthentication.new(user, { info: {name: 'komagata_discord'} })
    result = discord_authentication.authenticate

    assert_equal result[:notice], 'Discordと連携しました'
    assert_equal result[:path], root_path
  end

  test '引数が不正な値の時' do
    user = users(:komagata)
    discord_authentication = DiscordAuthentication.new(nil, { info: {name: 'komagata_discord'} })
    result = discord_authentication.authenticate

    assert_equal result[:alert], 'Discordの連携に失敗しました'
    assert_equal result[:path], root_path
  end
end
