# frozen_string_literal: true

class LinearScale < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :survey_question
  before_save :normalize_blank_linear_scale!

  with_options if: -> { survey_question.format == 'linear_scale' }, presence: true do
    validates :first
    validates :last
    validates :title_of_reason
  end
end
