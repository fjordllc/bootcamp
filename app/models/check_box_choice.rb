# frozen_string_literal: true

class CheckBoxChoice < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :check_box
  before_save do
    columns = %i[choices]
    normalize_blank!(columns)
  end

  validates :choices, presence: true, if: -> { check_box.survey_question.format == 'check_box' }
end
