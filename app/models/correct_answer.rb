# frozen_string_literal: true

class CorrectAnswer < Answer
  belongs_to :question

  def url
    Rails.application.routes.url_helpers.question_path(question, anchor: "answer_#{id}")
  end

  def formatted_summary(word)
    return description if word.blank?

    description.gsub(/(#{Regexp.escape(word)})/i, '<strong class="matched_word">\1</strong>')
  end
end
