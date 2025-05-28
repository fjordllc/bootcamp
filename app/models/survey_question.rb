# frozen_string_literal: true

class SurveyQuestion < ApplicationRecord
  belongs_to :user
  has_one :linear_scale, dependent: :destroy
  accepts_nested_attributes_for :linear_scale, allow_destroy: true
  validates_associated :linear_scale
  has_one :radio_button, dependent: :destroy
  accepts_nested_attributes_for :radio_button, allow_destroy: true
  validates_associated :radio_button
  has_one :check_box, dependent: :destroy
  accepts_nested_attributes_for :check_box, allow_destroy: true
  validates_associated :check_box
  has_many :survey_question_listings, dependent: :destroy
  has_many :surveys, through: :survey_question_listings
  has_many :survey_question_answers, dependent: :destroy

  enum format: {
    text_area: 0,
    text_field: 1,
    radio_button: 2,
    check_box: 3,
    linear_scale: 4
  }, _prefix: true

  validates :title, presence: true

  def answer_required_choice_exists?(survey_question_id)
    if self.format == 'radio_button'
      SurveyQuestion.joins(radio_button: :radio_button_choices)
                    .where(radio_button_choices: { reason_for_choice_required: true })
                    .exists?(survey_question_id)
    else
      SurveyQuestion.joins(check_box: :check_box_choices)
                    .where(check_box_choices: { reason_for_choice_required: true })
                    .exists?(survey_question_id)
    end
  end
end
