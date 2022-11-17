# frozen_string_literal: true

class RadioButton < ApplicationRecord
  belongs_to :survey_question
  has_many :radio_button_choices, dependent: :destroy
  accepts_nested_attributes_for :radio_button_choices, allow_destroy: true
  validates_associated :radio_button_choices

  with_options if: -> { survey_question.format == 'radio_button' }, presence: true do
    validates :radio_button_choices
    validates :title_of_reason
  end
end
