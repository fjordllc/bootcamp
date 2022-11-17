# frozen_string_literal: true

class RadioButtonChoice < ApplicationRecord
  belongs_to :radio_button

  validates :choices, presence: true, if: -> { radio_button.survey_question.format == 'radio_button' }
end
