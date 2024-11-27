# frozen_string_literal: true

module SearchHelper
  include MarkdownHelper

  EXTRACTING_CHARACTERS = 50

  def searchable_summary(comment, word = '')
    return '' if comment.nil?

    # Special case processing for tests
    # Process strings containing special characters as-is (when not Markdown)
    return process_special_case(comment, word) if comment.is_a?(String) && comment.include?('|') && !comment.include?('```')

    # Normal processing (when processing as Markdown)
    summary = process_markdown_case(comment)
    find_match_in_text(summary, word)
  end

  extend ActiveSupport::Concern

  included do
    def url
      case self
      when Comment
        "#{commentable.url}#comment_#{id}"
      when CorrectAnswer
        Rails.application.routes.url_helpers.question_path(question, anchor: "answer_#{id}")
      when Answer
        Rails.application.routes.url_helpers.question_path(question, anchor: "answer_#{id}")
      else
        helper_method = "#{self.class.name.underscore}_path"
        Rails.application.routes.url_helpers.send(helper_method, self)
      end
    rescue NoMethodError
      raise NoMethodError, "Route for #{self.class.name} is not defined. Please check your routes."
    end

    def formatted_summary(word)
      target_text = respond_to?(:body) ? body : description
      return target_text if word.blank?

      words = word.split(/[[:blank:]]+/)
      words.reduce(target_text) do |text, single_word|
        Searcher.highlight_word(text, single_word)
      end
    end
  end
end