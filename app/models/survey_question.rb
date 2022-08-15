# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  belongs_to :user
  has_one :linear_scale, dependent: :destroy
  accepts_nested_attributes_for :linear_scale, allow_destroy: true
  has_one :radio_button, dependent: :destroy
  accepts_nested_attributes_for :radio_button, allow_destroy: true
  has_one :check_box, dependent: :destroy
  accepts_nested_attributes_for :check_box, allow_destroy: true

  enum question_format: {
    text_field: 0,
    text_area: 1,
    radio_button: 2,
    check_box: 3,
    linear_scale: 4
  }, _prefix: true
end
