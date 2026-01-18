# frozen_string_literal: true

module SmartSearch
  class EmbeddingGenerator
    MODEL = 'text-embedding-3-small'

    def initialize
      @api_available = ENV['OPENAI_API_KEY'].present?
    end

    def api_available?
      @api_available
    end

    def generate(text)
      return nil unless api_available?
      return nil if text.blank?

      normalized = normalize_text(text)
      return nil if normalized.blank?

      response = RubyLLM.embed(normalized, model: MODEL)
      response.vectors.first
    rescue StandardError => e
      Rails.logger.error "[SmartSearch] Embedding generation failed: #{e.message}"
      nil
    end

    def generate_batch(texts)
      return [] unless api_available?
      return [] if texts.blank?

      normalized = texts.map { |t| normalize_text(t) }.compact
      return [] if normalized.empty?

      response = RubyLLM.embed(normalized, model: MODEL)
      response.vectors
    rescue StandardError => e
      Rails.logger.error "[SmartSearch] Batch embedding generation failed: #{e.message}"
      []
    end

    private

    def normalize_text(text)
      return '' if text.blank?

      sanitized = ActionView::Base.full_sanitizer.sanitize(text)
      sanitized = sanitized.gsub(/\s+/, ' ').strip
      sanitized.truncate(Configuration::MAX_TEXT_LENGTH, omission: '')
    end
  end
end
