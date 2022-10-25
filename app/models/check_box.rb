# frozen_string_literal: true

class CheckBox < ApplicationRecord
  include SurveyQuestionFormat
  belongs_to :survey_question
  has_many :check_box_choices, dependent: :destroy
  accepts_nested_attributes_for :check_box_choices, allow_destroy: true
  validates_associated :check_box_choices
  before_save do
    columns = %i[title_of_reason description_of_reason]
    normalize_blank!(columns)
  end

  with_options if: -> { survey_question.format == 'check_box' }, presence: true do
    validates :check_box_choices
    validates :title_of_reason
  end
end
