# frozen_string_literal: true

class CheckBoxChoice < ApplicationRecord
  belongs_to :check_box
  before_save :normalize_blank_values

  validates :choices, presence: true, if: -> { check_box.survey_question.question_format == 'check_box' }

  def normalize_blank_values
    %i[choices].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
