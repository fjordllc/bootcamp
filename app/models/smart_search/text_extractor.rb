# frozen_string_literal: true

module SmartSearch
  module TextExtractor
    MAX_CHARS = 15_000

    module_function

    def extract_text_content(record)
      text = case record
             when Practice
               [record.title, record.description].compact.join(' ')
             when Report
               [record.title, record.description].compact.join(' ')
             when Product
               record.body
             when Page
               [record.title, record.body].compact.join(' ')
             when Question
               [record.title, record.description].compact.join(' ')
             when Announcement
               [record.title, record.description].compact.join(' ')
             when Event
               [record.title, record.description].compact.join(' ')
             when RegularEvent
               [record.title, record.description].compact.join(' ')
             when FAQ
               [record.question, record.answer].compact.join(' ')
             when Answer, SubmissionAnswer
               record.description
             else
               Rails.logger.warn "Unknown model type for embedding generation: #{record.class.name}"
               nil
             end

      limit_text_length(text)
    end

    def limit_text_length(text)
      return nil if text.blank?

      if text.length > MAX_CHARS
        truncated_text = text[0...MAX_CHARS]
        Rails.logger.warn "Text truncated from #{text.length} to #{MAX_CHARS} characters for embedding generation"
        truncated_text
      else
        text
      end
    end
  end
end
