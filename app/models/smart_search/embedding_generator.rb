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

      valid_entries = extract_valid_entries(texts)
      return Array.new(texts.size) if valid_entries.empty?

      vectors = fetch_embeddings(valid_entries.map(&:first))
      build_result_array(texts.size, valid_entries, vectors)
    rescue StandardError => e
      Rails.logger.error "[SmartSearch] Batch embedding generation failed: #{e.message}"
      []
    end

    private

    def extract_valid_entries(texts)
      texts.each_with_index.map { |t, i| [normalize_text(t), i] }.reject { |t, _| t.blank? }
    end

    def fetch_embeddings(valid_texts)
      RubyLLM.embed(valid_texts, model: MODEL).vectors
    end

    def build_result_array(size, valid_entries, vectors)
      result = Array.new(size)
      valid_entries.each_with_index do |(_, original_index), response_index|
        result[original_index] = vectors[response_index]
      end
      result
    end

    def normalize_text(text)
      return '' if text.blank?

      sanitized = ActionView::Base.full_sanitizer.sanitize(text)
      sanitized = sanitized.gsub(/\s+/, ' ').strip
      sanitized.truncate(Configuration::MAX_TEXT_LENGTH, omission: '')
    end
  end
end
