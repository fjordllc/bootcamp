# frozen_string_literal: true

class DiscordMember
  # NOTE: https://discord.com/developers/docs/resources/guild#search-guild-members の limit の初期値は 1 だが、
  #       ユーザー名またはニックネームの前方一致となるため、limit を 10 にしてニックネームで一致した場合を考慮した
  RECORD_LIMIT_OF_FORWARD_MATCH = 10

  attr_reader :account_name

  class << self
    def find_by(account_name:)
      return nil if account_name.blank?
      return nil unless ready?

      username = account_name.split('#').first
      query = {
        query: username,
        limit: RECORD_LIMIT_OF_FORWARD_MATCH
      }.to_query
      response = Discord::Resource.get("#{site_base}/search?#{query}")
      return nil unless response.is_a?(Net::HTTPSuccess)

      result = JSON.parse(response.body, symbolize_names: true)
      discord_members = result.map { |attrs| DiscordMember.new(attrs) }
      discord_members.find { |member| account_name == member.account_name }
    rescue Timeout::Error
      Rails.logger.error '[Discord API] APIへの接続がタイムアウトしました。'
      nil
    rescue StandardError => e
      Rails.logger.error "[Discord API] 予期せぬエラーが発生しました。：#{e.message}"
      nil
    end

    def site_base
      "guilds/#{guild_id}/members"
    end

    private

    def ready?
      !!guild_id
    end

    def guild_id
      ENV['DISCORD_GUILD_ID'].presence
    end
  end

  def initialize(attributes = {})
    user = attributes[:user]

    @account_id = user[:id]
    @account_name = [
      user[:username],
      user[:discriminator]
    ].join('#')

    @bot = user[:bot]
    @role_ids = attributes[:roles]
  end

  def destroy
    return false if @bot
    return false unless @role_ids.empty?

    response = Discord::Resource.delete("#{self.class.site_base}/#{@account_id}")
    return false unless response.is_a?(Net::HTTPSuccess)

    true
  rescue Timeout::Error
    Rails.logger.error '[Discord API] APIへの接続がタイムアウトしました。'
    false
  rescue StandardError => e
    Rails.logger.error "[Discord API] 予期せぬエラーが発生しました。：#{e.message}"
    false
  end
end
