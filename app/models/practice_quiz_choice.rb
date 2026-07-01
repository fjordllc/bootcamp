# frozen_string_literal: true

class PracticeQuizChoice < ApplicationRecord
  belongs_to :practice_quiz_question
  has_many :practice_quiz_answers, dependent: :restrict_with_error

  validates :body, presence: true
  validates :position, presence: true
end
