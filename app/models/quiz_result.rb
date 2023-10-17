class QuizResult < ApplicationRecord
  belongs_to :quiz
  belongs_to :user
  has_many :responses, dependent: :destroy
end
