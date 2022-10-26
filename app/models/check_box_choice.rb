# frozen_string_literal: true

class CheckBoxChoice < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :check_box
  before_save :normalize_blank_check_box_choice_and_radio_button_choice!

  validates :choices, presence: true, if: -> { check_box.survey_question.format == 'check_box' }
end
