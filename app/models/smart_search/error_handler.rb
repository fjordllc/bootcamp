# frozen_string_literal: true

module SmartSearch
  module ErrorHandler
    extend ActiveSupport::Concern

    private

    def handle_embedding_error(error, context = '')
      case error
      when Google::Cloud::InvalidArgumentError
        if error.message.include?('token count')
          log_error("API Token Limit Error #{context}: #{error.message}", :token_limit)
          { success: false, error_type: :token_limit, message: error.message }
        else
          log_error("API Error #{context}: #{error.message}", :api_error)
          { success: false, error_type: :api_error, message: error.message }
        end
      else
        log_error("Unexpected error #{context}: #{error.class.name} - #{error.message}", :general_error)
        log_error("Backtrace: #{error.backtrace[0..3].join('; ')}", :general_error)

        raise error if Rails.env.development?

        { success: false, error_type: :general_error, message: error.message }

      end
    end

    def log_error(message, level = :error)
      case level
      when :warn
        Rails.logger.warn "❌ #{message}"
        SmartSearch::Logger.warn(message)
      else
        Rails.logger.error "❌ #{message}"
        SmartSearch::Logger.error(message)
      end
    end

    def log_info(message)
      Rails.logger.info message
      SmartSearch::Logger.info(message)
    end
  end
end
