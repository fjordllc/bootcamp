# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class ConvertInviteUrlOfTimesUrlToChannelUrl < ActiveRecord::Migration[6.1]
  def up
    User.where.not(times_url: nil).find_each do |user|
      match = user.times_url.match(%r{\Ahttps://discord.gg/(\w+)\z})
      next if match.nil?

      invite_code = match.captures.first
      begin
        channel_url = fetch_channel_url(invite_code)
      rescue RuntimeError => e
        Rails.logger.error "[Discord API] チャンネルURLを取得できません。:#{e.message}"
        break
      end

      Rails.logger.warn "[Discord API] 無効な招待URLです。:#{user.login_name} #{user.times_url}" if channel_url.nil?

      user.update!(times_url: channel_url)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fetch_channel_url(invite_code)
    uri = URI("https://discord.com/api/invites/#{invite_code}")
    res = Net::HTTP.get_response(uri)

    case res
    when Net::HTTPSuccess
      data = JSON.parse(res.body)
      "https://discord.com/channels/#{data['guild']['id']}/#{data['channel']['id']}"
    when Net::HTTPNotFound
      nil
    when Net::HTTPTooManyRequests
      raise 'Too Many Requests'
    end
  end
end
