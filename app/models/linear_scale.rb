# frozen_string_literal: true

class LinearScale < ApplicationRecord
  belongs_to :survey_question

  with_options if: -> { survey_question.question_format == 'linear_scale' }, presence: true do
    validates :start_of_scale
    validates :end_of_scale
    validates :title_of_reason_for_choice
  end
end
