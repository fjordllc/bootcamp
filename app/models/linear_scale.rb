# frozen_string_literal: true

class LinearScale < ApplicationRecord
  belongs_to :survey_question
  before_save :normalize_blank_values

  with_options if: -> { survey_question.format == 'linear_scale' }, presence: true do
    validates :start_of_scale
    validates :end_of_scale
    validates :title_of_reason_for_choice
  end

  def normalize_blank_values
    %i[start_of_scale end_of_scale title_of_reason_for_choice description_of_reason_for_choice].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
