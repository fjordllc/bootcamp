# frozen_string_literal: true

class SurveyQuestionListing < ApplicationRecord
  belongs_to :survey
  belongs_to :survey_question
end
