# frozen_string_literal: true

module SmartSearch
  class Configuration
    EMBEDDING_MODEL = 'text-multilingual-embedding-002'
    EMBEDDING_DIMENSION = 768
    BATCH_SIZE = 40
    MAX_TOKENS = 20_000
    SIMILARITY_THRESHOLD = 0.7
    DEFAULT_LIMIT = 50

    # Embedding対象のモデル
    EMBEDDING_MODELS = %w[Practice Report Product Page Question Announcement Event RegularEvent FAQ Answer SubmissionAnswer].freeze

    # モデル名からクラスへのマッピング
    MODEL_MAPPINGS = {
      practices: Practice,
      reports: Report,
      products: Product,
      pages: Page,
      questions: Question,
      announcements: Announcement,
      events: Event,
      regular_events: RegularEvent,
      faqs: FAQ,
      answers: Answer
    }.freeze

    class << self
      def embedding_models
        EMBEDDING_MODELS.map(&:constantize)
      end

      def type_to_model(document_type)
        MODEL_MAPPINGS[document_type.to_sym]
      end
    end
  end
end
