# frozen_string_literal: true

require 'test_helper'

class Authentication::DiscordTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: 'www.example.com', protocol: 'https' }
  end

  test 'authentication succeeds when arguments are valid' do
    user = users(:komagata)
    discord_authentication = Authentication::Discord.new(user, { info: { name: 'komagata_discord' } })
    result = discord_authentication.authenticate

    assert_equal result[:notice], 'Discordと連携しました'
    assert_equal result[:path], root_path
  end

  test 'authentication fails when arguments are invalid' do
    discord_authentication = Authentication::Discord.new(nil, { info: { name: 'komagata_discord' } })
    result = discord_authentication.authenticate

    assert_equal result[:alert], 'Discordの連携に失敗しました'
    assert_equal result[:path], root_path
  end
end
