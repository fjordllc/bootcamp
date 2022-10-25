# frozen_string_literal: true

class RadioButtonChoice < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :radio_button
  before_save do
    columns = %i[choices]
    normalize_blank!(columns)
  end

  validates :choices, presence: true, if: -> { radio_button.survey_question.format == 'radio_button' }
end
