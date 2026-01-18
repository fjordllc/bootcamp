# frozen_string_literal: true

module SmartSearch
  class Configuration
    EMBEDDING_DIMENSION = 1536
    BATCH_SIZE = 50
    MAX_TEXT_LENGTH = 8000
    DEFAULT_LIMIT = 50

    EMBEDDING_MODELS = %w[
      Practice Report Product Page Question Announcement
      Event RegularEvent Answer CorrectAnswer Comment
    ].freeze

    class << self
      def embedding_models
        EMBEDDING_MODELS.map(&:constantize)
      end
    end
  end
end
