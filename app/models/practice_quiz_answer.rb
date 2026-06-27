# frozen_string_literal: true

class PracticeQuizAnswer < ApplicationRecord
  belongs_to :practice_quiz_attempt
  belongs_to :practice_quiz_question
  belongs_to :practice_quiz_choice
end
