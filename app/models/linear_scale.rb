# frozen_string_literal: true

class LinearScale < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :survey_question
  before_save do
    columns = %i[first last title_of_reason description_of_reason]
    normalize_blank!(columns)
  end

  with_options if: -> { survey_question.format == 'linear_scale' }, presence: true do
    validates :first
    validates :last
    validates :title_of_reason
  end
end
