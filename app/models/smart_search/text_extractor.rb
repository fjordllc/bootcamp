# frozen_string_literal: true

module SmartSearch
  module TextExtractor
    module_function

    def extract(record)
      text = case record
             when Practice
               [record.title, record.description, record.goal].compact.join("\n\n")
             when Report
               [record.title, record.description].compact.join("\n\n")
             when Product
               record.body
             when Page
               [record.title, record.body].compact.join("\n\n")
             when Question
               [record.title, record.description].compact.join("\n\n")
             when Announcement
               [record.title, record.description].compact.join("\n\n")
             when Event, RegularEvent
               [record.title, record.description].compact.join("\n\n")
             when Answer, CorrectAnswer, Comment
               record.description
             else
               Rails.logger.warn "[SmartSearch] Unknown model type: #{record.class.name}"
               nil
             end

      truncate_text(text)
    end

    def truncate_text(text)
      return nil if text.blank?

      text.length > Configuration::MAX_TEXT_LENGTH ? text[0...Configuration::MAX_TEXT_LENGTH] : text
    end
  end
end
