# frozen_string_literal: true

module Discord
  class TimesChannel
    class << self
      def to_channel_name(username)
        username.downcase
      end
    end

    def initialize(username)
      @name = Discord::TimesChannel.to_channel_name(username)
    end

    def save
      @channel = Discord::Server.create_text_channel(
        name: @name,
        parent: Discord::TimesCategory.categorize_by_initials(@name)
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
