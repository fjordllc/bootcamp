# frozen_string_literal: true

class LinearScale < ApplicationRecord
  belongs_to :survey_question
  before_save :normalize_blank_values

  with_options if: -> { survey_question.format == 'linear_scale' }, presence: true do
    validates :first
    validates :last
    validates :title_of_reason
  end

  def normalize_blank_values
    %i[first last title_of_reason description_of_reason].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
