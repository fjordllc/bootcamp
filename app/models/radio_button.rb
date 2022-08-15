# frozen_string_literal: true

class RadioButton < ApplicationRecord
  belongs_to :survey_question
  has_many :radio_button_choices, dependent: :destroy
  accepts_nested_attributes_for :radio_button_choices, allow_destroy: true
end
