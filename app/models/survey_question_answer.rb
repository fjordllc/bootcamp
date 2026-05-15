# frozen_string_literal: true

class SurveyQuestionAnswer < ApplicationRecord
  belongs_to :survey_answer
  belongs_to :survey_question

  validates :answer, presence: true, if: -> { survey_question.answer_required }
  validates :reason, presence: true, if: :reason_required?

  private

  def reason_required?
    case survey_question.format
    when 'radio_button'
      survey_question.radio_button.radio_button_choices.exists?(choices: answer, reason_for_choice_required: true)
    when 'check_box'
      survey_question.check_box.check_box_choices.exists?(choices: answer, reason_for_choice_required: true)
    when 'linear_scale'
      survey_question.linear_scale.reason_for_choice_required
    else
      false
    end
  end
end
