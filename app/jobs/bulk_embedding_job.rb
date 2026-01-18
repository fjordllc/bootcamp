# frozen_string_literal: true

class BulkEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(model_name: nil, force_regenerate: false)
    generator = SmartSearch::EmbeddingGenerator.new
    unless generator.api_available?
      Rails.logger.info '[SmartSearch] Bulk embedding skipped - API key not configured'
      return
    end

    models = model_name ? [model_name] : SmartSearch::Configuration::EMBEDDING_MODELS
    models.each { |name| process_model(name, force_regenerate, generator) }
  end

  private

  def process_model(model_name, force_regenerate, generator)
    model_class = model_name.constantize
    return unless model_class.column_names.include?('embedding')

    scope = force_regenerate ? model_class.all : model_class.where(embedding: nil)
    total = scope.count

    Rails.logger.info "[SmartSearch] Processing #{total} #{model_name} records"

    scope.find_in_batches(batch_size: SmartSearch::Configuration::BATCH_SIZE) do |batch|
      process_batch(batch, generator)
      sleep(0.1)
    end

    Rails.logger.info "[SmartSearch] Completed #{model_name} embedding generation"
  end

  def process_batch(records, generator)
    valid_pairs = extract_valid_pairs(records)
    return if valid_pairs.empty?

    embeddings = generator.generate_batch(valid_pairs.map(&:last))
    return unless valid_embedding_count?(embeddings, valid_pairs)

    update_embeddings(valid_pairs, embeddings)
  rescue StandardError => e
    Rails.logger.error "[SmartSearch] Batch processing failed: #{e.message}"
  end

  def extract_valid_pairs(records)
    texts = records.map { |r| SmartSearch::TextExtractor.extract(r) }
    records.zip(texts).select { |_, text| text.present? }
  end

  def valid_embedding_count?(embeddings, valid_pairs)
    return true if embeddings.size == valid_pairs.size

    Rails.logger.warn "[SmartSearch] Embedding count mismatch: expected #{valid_pairs.size}, got #{embeddings.size}"
    false
  end

  def update_embeddings(valid_pairs, embeddings)
    valid_pairs.each_with_index do |(record, _), index|
      next if embeddings[index].blank?

      record.update_column(:embedding, embeddings[index]) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
