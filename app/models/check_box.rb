# frozen_string_literal: true

class CheckBox < ApplicationRecord
  belongs_to :survey_question
  has_many :check_box_choices, dependent: :destroy
  accepts_nested_attributes_for :check_box_choices, allow_destroy: true

  validates :title_of_reason_for_choice, presence: true, if: -> { survey_question.question_format == 'check_box' }
end
