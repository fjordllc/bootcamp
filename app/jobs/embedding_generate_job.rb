# frozen_string_literal: true

class EmbeddingGenerateJob < ApplicationJob
  include SmartSearch::ErrorHandler

  queue_as :default

  def perform(model_name:, record_id:)
    model_class = model_name.constantize
    record = model_class.find_by(id: record_id)

    return if record.nil?

    text_content = SmartSearch::TextExtractor.extract_text_content(record)
    return if text_content.blank?

    begin
      generator = SmartSearch::EmbeddingGenerator.new
      
      # Credentials not available - skip silently
      unless generator.instance_variable_get(:@credentials_available)
        Rails.logger.debug "Skipping embedding generation for #{model_name}##{record_id} - credentials not available"
        return
      end
      
      embedding = generator.generate_embedding(text_content)

      if embedding.present?
        # Vector型として保存するために配列を文字列形式に変換
        vector_string = "[#{embedding.join(',')}]"
        # SQL安全な方法で更新
        record.class.where(id: record.id).update_all(embedding: vector_string)
        log_info "Generated embedding for #{model_name}##{record_id}"
      else
        log_error "Failed to generate embedding for #{model_name}##{record_id}", :warn
      end
    rescue StandardError => e
      # Don't raise error for missing credentials - just log and continue
      if e.message.include?('credentials') || e.message.include?('GOOGLE')
        Rails.logger.debug "Embedding generation skipped: #{e.message}"
      else
        handle_embedding_error(e, "for #{model_name}##{record_id}")
      end
    end
  end
end
