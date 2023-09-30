class Quiz < ApplicationRecord
  has_many :quiz_questions, dependent: :destroy
end
