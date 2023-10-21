# frozen_string_literal: true

class Statement < ApplicationRecord
  belongs_to :quiz
  has_many :responses, dependent: :destroy

  validates :body, presence: true, length: { maximum: 400 }
  validates :is_correct, inclusion: { in: [true, false], message: '%{value} を選択してください' }
end
