# frozen_string_literal: true

class CheckBox < ApplicationRecord
  belongs_to :survey_question
  has_many :check_box_choices, dependent: :destroy
  accepts_nested_attributes_for :check_box_choices, allow_destroy: true
  validates_associated :check_box_choices
  before_save :normalize_blank_values

  with_options if: -> { survey_question.format == 'check_box' }, presence: true do
    validates :check_box_choices
    validates :title_of_reason
  end

  def normalize_blank_values
    %i[title_of_reason description_of_reason].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
