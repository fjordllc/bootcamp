# frozen_string_literal: true

class QuizResult < ApplicationRecord
  belongs_to :quiz
  belongs_to :user
  has_many :responses, dependent: :destroy

  attribute :score, default: 0

  def set_score
    correct_responses = responses.select do |response|
      response.answer == response.statement.is_correct
    end

    self.score = correct_responses.count
    save
  end
end
