# frozen_string_literal: true

class CorrectAnswer < Answer
  belongs_to :question

  def search_label
    I18n.t('activerecord.search_labels.correct_answer')
  end
end
