# frozen_string_literal: true

class CheckBox < ApplicationRecord
  belongs_to :survey_question
  has_many :check_box_choices, dependent: :destroy
  accepts_nested_attributes_for :check_box_choices, allow_destroy: true
  validates_associated :check_box_choices

  with_options if: -> { survey_question.format == 'check_box' }, presence: true do
    validates :check_box_choices
    validates :title_of_reason
  end
end
