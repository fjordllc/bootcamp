# frozen_string_literal: true

module Discord
  class Server
    class_attribute :guild_id, :authorize_token, instance_accessor: false

    class << self
      def create_text_channel(name:, parent: nil)
        guild = Discord::Server.find_by(id: guild_id, token: authorize_token)
        if guild.blank?
          Rails.logger.error "[Discord API] Do not find server. guild_id: #{guild_id}, token: #{authorize_token}"
          return nil
        end

        channel_type = Discordrb::Channel::TYPES[:text]
        guild.create_channel(name, channel_type, parent:)
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def delete_text_channel(channel_id)
        response = Discordrb::API::Channel.delete(authorize_token, channel_id)
        response.code == 200
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def find_by(id:, token:)
        return nil unless enabled?

        guild_json = Discordrb::API::Server.resolve(token, id)
        guild_body = JSON.parse(guild_json.body)

        bot = Discordrb::Bot.new(token:, log_mode: :silent)
        Discordrb::Server.new(guild_body, bot)
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def categories(keyword: nil)
        channels = Discord::Server.channels(id: guild_id, token: authorize_token)
        categories = channels&.select(&:category?)
        categories&.select { |category| /#{keyword}/.match? category.name }
      end

      def channels(id:, token:)
        return nil unless enabled?

        channels_response = Discordrb::API::Server.channels(token, id)
        channels_data = JSON.parse(channels_response.body)

        bot = Discordrb::Bot.new(token:, log_mode: :silent)
        channels_data.map { |channel_data| Discordrb::Channel.new(channel_data, bot) }
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
      end

      def enabled?
        guild_id && authorize_token
      end

      def find_member_id(member_name:)
        return nil unless enabled?

        limit = 1000
        guild_members_json = Discordrb::API::Server.resolve_members(authorize_token, guild_id, limit)
        guild_members = JSON.parse(guild_members_json.body)
        target_member = guild_members.select { |member| member['user']['username'] == member_name }
        target_member.empty? ? nil : target_member[0]['user']['id']
      rescue Discordrb::Errors::CodeError => e
        log_error(e)
        nil
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
