# frozen_string_literal: true

module Discord
  class Server
    include ActiveSupport::Configurable
    config_accessor :guild_id, :authorize_token, instance_accessor: false

    class << self
      def create_text_channel(name:, parent: nil)
        guild = Discord::Server.find_by(id: guild_id, token: authorize_token)
        return nil if guild.blank?

        channel_type = Discordrb::Channel::TYPES[:text]
        guild.create_channel(name, channel_type, parent: parent)
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def find_by(id:, token:)
        return nil unless enabled?

        guild_json = Discordrb::API::Server.resolve(token, id)
        guild_body = JSON.parse(guild_json.body)

        bot = Discordrb::Bot.new(token: token, log_mode: :silent)
        Discordrb::Server.new(guild_body, bot)
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def enabled?
        guild_id && authorize_token
      end

      private

      def log_error(exception)
        # NOTE: full_message の例
        #       - Maximum number of server channels reached (500)
        #       - Maximum number of channels in category reached (50)
        #       - The bot doesn't have the required permission to do this!
        Rails.logger.error "[Discord API] #{exception.full_message.chomp}"
      end
    end
  end
end
