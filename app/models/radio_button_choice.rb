# frozen_string_literal: true

class RadioButtonChoice < ApplicationRecord
  belongs_to :radio_button
  before_save :normalize_blank_values

  validates :choices, presence: true, if: -> { radio_button.survey_question.format == 'radio_button' }

  def normalize_blank_values
    %i[choices].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
