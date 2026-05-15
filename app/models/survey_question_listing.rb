# frozen_string_literal: true

class SurveyQuestionListing < ApplicationRecord
  default_scope -> { order(:position) }
  belongs_to :survey
  belongs_to :survey_question
  acts_as_list scope: :survey
end
