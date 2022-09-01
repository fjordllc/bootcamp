# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  belongs_to :creator, class_name: 'User', optional: true
  belongs_to :updater, class_name: 'User', optional: true
  has_one :linear_scale, dependent: :destroy
  accepts_nested_attributes_for :linear_scale, allow_destroy: true
  has_one :radio_button, dependent: :destroy
  accepts_nested_attributes_for :radio_button, allow_destroy: true
  has_one :check_box, dependent: :destroy
  accepts_nested_attributes_for :check_box, allow_destroy: true

  enum question_format: {
    text_area: 0,
    text_field: 1,
    radio_button: 2,
    check_box: 3,
    linear_scale: 4
  }, _prefix: true

  validates :question_title, presence: true
end
