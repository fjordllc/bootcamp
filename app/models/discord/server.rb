# frozen_string_literal: true

module Discord
  class Server
    TOKEN_PREFIX_SIZE = 4

    class << self
      class_attribute :guild_id, :authorize_token, instance_reader: false

      def create_text_channel(name:, parent: nil)
        guild = Discord::Server.find_by(id: guild_id, token: authorize_token)
        return nil if guild.blank?

        channel_type = Discordrb::Channel::TYPES[:text]
        guild.create_channel(name, channel_type, parent: parent)
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def guild_id
        @guild_id || ENV['DISCORD_GUILD_ID'].presence
      end

      def authorize_token
        @authorize_token || "Bot #{ENV['DISCORD_BOT_TOKEN']}"
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
        guild_id && authorize_token.size > TOKEN_PREFIX_SIZE
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
