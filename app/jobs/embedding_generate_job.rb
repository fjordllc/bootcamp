# frozen_string_literal: true

class EmbeddingGenerateJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(model_name:, record_id:)
    record = model_name.constantize.find_by(id: record_id)
    return if record.nil?

    generator = SmartSearch::EmbeddingGenerator.new
    return unless generator.api_available?

    text = SmartSearch::TextExtractor.extract(record)
    return if text.blank?

    embedding = generator.generate(text)
    return if embedding.blank?

    record.update_column(:embedding, embedding) # rubocop:disable Rails/SkipsModelValidations
    Rails.logger.info "[SmartSearch] Generated embedding for #{model_name}##{record_id}"
  end
end
