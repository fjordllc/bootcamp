# frozen_string_literal: true

module Discord
  class TimesChannel
    class_attribute :category_id, instance_reader: false

    class << self
      def to_channel_name(username)
        username.downcase
      end

      def category_id
        @category_id || ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID'].presence
      end
    end

    def initialize(username)
      @name = Discord::TimesChannel.to_channel_name(username)
    end

    def save
      @channel = Discord::Server.create_text_channel(
        name: @name,
        parent: Discord::TimesChannel.category_id
      )

      !!@channel
    end

    def id
      @channel&.id&.to_s
    end

    def category_id
      @channel&.parent_id&.to_s
    end
  end
end
