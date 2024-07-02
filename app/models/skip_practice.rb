# frozen_string_literal: true

class SkipPractice < ApplicationRecord
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
            presence: true,
            uniqueness: { scope: :user_id }
end
