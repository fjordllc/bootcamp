# frozen_string_literal: true

class EmbeddingGenerateJob < ApplicationJob
  queue_as :default

  def perform(model_name:, record_id:)
    model_class = model_name.constantize
    record = model_class.find_by(id: record_id)

    return if record.nil?

    text_content = extract_text_content(record)
    return if text_content.blank?

    generator = SmartSearch::EmbeddingGenerator.new
    embedding = generator.generate_embedding(text_content)

    if embedding.present?
      # Vector型として保存するために配列を文字列形式に変換
      vector_string = "[#{embedding.join(',')}]"
      # SQL安全な方法で更新
      record.class.where(id: record.id).update_all(embedding: vector_string)
      Rails.logger.info "Generated embedding for #{model_name}##{record_id}"
    else
      Rails.logger.warn "Failed to generate embedding for #{model_name}##{record_id}"
    end
  rescue StandardError => e
    Rails.logger.error "Error generating embedding for #{model_name}##{record_id}: #{e.message}"
    raise e
  end

  private

  def extract_text_content(record)
    case record
    when Practice
      [record.title, record.description].compact.join(' ')
    when Report
      [record.title, record.description].compact.join(' ')
    when Product
      record.body
    when Page
      [record.title, record.body].compact.join(' ')
    when Question
      [record.title, record.body, record.description].compact.join(' ')
    when Announcement
      [record.title, record.description].compact.join(' ')
    when Event
      [record.title, record.description].compact.join(' ')
    when RegularEvent
      [record.title, record.description].compact.join(' ')
    when FAQ
      [record.question, record.answer].compact.join(' ')
    when Answer
      record.description
    else
      Rails.logger.warn "Unknown model type for embedding generation: #{record.class.name}"
      nil
    end
  end
end
