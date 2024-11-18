# frozen_string_literal: true

class CorrectAnswer < Answer
  belongs_to :question

  def url
    Rails.application.routes.url_helpers.api_answer_correct_answer_path(answer_id: question_id, id: id)
  end

  def formatted_summary(word)
    return description unless word.present?

    description.gsub(/(#{Regexp.escape(word)})/i, '<strong class="matched_word">\1</strong>')
  end
end
