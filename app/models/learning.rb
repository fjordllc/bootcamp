# frozen_string_literal: true

class Learning < ActiveRecord::Base
  enum status: { not_complete: 0, started: 1, submitted: 2, complete: 3 }
  belongs_to :user, touch: true
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
    presence: true,
    uniqueness: { scope: :user_id }
end
