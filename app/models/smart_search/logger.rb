# frozen_string_literal: true

module SmartSearch
  class Logger
    class << self
      def logger
        @logger ||= ::Logger.new(Rails.root.join('log/embedding.log')).tap do |logger|
          logger.level = ::Logger::INFO
          logger.formatter = proc do |severity, datetime, _progname, msg|
            "[#{datetime.strftime('%H:%M:%S')}] #{severity}: #{msg}\n"
          end
        end
      end

      delegate :info, to: :logger

      delegate :warn, to: :logger

      delegate :error, to: :logger

      def debug(message)
        logger.debug(message) if Rails.env.development?
      end
    end
  end
end
