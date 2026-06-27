# frozen_string_literal: true

class PracticeQuizChoice < ApplicationRecord
  belongs_to :practice_quiz_question

  validates :body, presence: true
  validates :position, presence: true
end
