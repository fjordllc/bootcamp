# frozen_string_literal: true

class CheckBoxChoice < ApplicationRecord
  belongs_to :check_box
  before_save :normalize_blank_values

  validates :choices, presence: true, if: -> { check_box.survey_question.format == 'check_box' }

  def normalize_blank_values
    columns = %i[choices]
    columns.each do |column|
      self[column] = nil if self[column].blank?
    end
  end
end
