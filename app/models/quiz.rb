class Quiz < ApplicationRecord
  has_many :quiz_questions, dependent: :destroy

  accepts_nested_attributes_for :quiz_questions, allow_destroy: true
end
