# frozen_string_literal: true

module SmartSearch
  module TextExtractor
    module_function

    def extract(record)
      text = extract_raw_text(record)
      truncate_text(text)
    end

    def extract_raw_text(record)
      case record
      when Practice then extract_practice(record)
      when Product then record.body
      when Answer, CorrectAnswer, Comment then record.description
      when Report, Page, Question, Announcement, Event, RegularEvent
        extract_title_description(record)
      else
        Rails.logger.warn "[SmartSearch] Unknown model type: #{record.class.name}"
        nil
      end
    end

    def extract_practice(record)
      [record.title, record.description, record.goal].compact.join("\n\n")
    end

    def extract_title_description(record)
      [record.title, record.description].compact.join("\n\n")
    end

    def truncate_text(text)
      return nil if text.blank?

      text.length > Configuration::MAX_TEXT_LENGTH ? text[0...Configuration::MAX_TEXT_LENGTH] : text
    end
  end
end
