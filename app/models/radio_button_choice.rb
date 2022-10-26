# frozen_string_literal: true

class RadioButtonChoice < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :radio_button
  before_save :normalize_blank_check_box_choice_and_radio_button_choice!

  validates :choices, presence: true, if: -> { radio_button.survey_question.format == 'radio_button' }
end
