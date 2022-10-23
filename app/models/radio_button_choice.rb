# frozen_string_literal: true

class RadioButtonChoice < ApplicationRecord
  belongs_to :radio_button
  before_save :normalize_blank_values

  validates :choices, presence: true, if: -> { radio_button.survey_question.format == 'radio_button' }

  def normalize_blank_values
    columns = %i[choices]
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end
end
