class Response < ApplicationRecord
  belongs_to :quiz_result
  belongs_to :statement

  after_save :update_quiz_score

  private

  def update_quiz_score
    quiz_result.calculate_score
  end
end
