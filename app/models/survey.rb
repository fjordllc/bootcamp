# frozen_string_literal: true

class Survey < ApplicationRecord
  belongs_to :user
  has_many :survey_question_listings, dependent: :destroy
  has_many :survey_questions, through: :survey_question_listings
end
