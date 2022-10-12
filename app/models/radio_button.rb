# frozen_string_literal: true

class RadioButton < ApplicationRecord
  belongs_to :survey_question
  has_many :radio_button_choices, dependent: :destroy
  accepts_nested_attributes_for :radio_button_choices, allow_destroy: true
  validates_associated :radio_button_choices
  before_save :normalize_blank_values

  with_options if: -> { survey_question.format == 'radio_button' }, presence: true do
    validates :radio_button_choices
    validates :title_of_reason
  end

  def normalize_blank_values
    %i[title_of_reason description_of_reason].each do |att|
      self[att] = nil if self[att].blank?
    end
  end
end
