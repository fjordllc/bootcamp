# frozen_string_literal: true

class LinearScale < ApplicationRecord
  belongs_to :survey_question

  with_options if: -> { survey_question.format == 'linear_scale' }, presence: true do
    validates :first
    validates :last
    validates :title_of_reason
  end
end
