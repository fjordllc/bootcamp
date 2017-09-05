class TaskRequest < ApplicationRecord
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true, uniqueness: { scope: :practice_id }
  validates :practice_id, presence: true, uniqueness: { scope: :user_id }
  validates :passed, inclusion: { in: [true, false] }
  validates :content, presence: true, length: { minimum: 5, maximum: 2000 }

  scope :passed, -> { where(passed: true,).order(created_at: :desc)  }
  scope :non_passed, -> { where(passed: false,).order(created_at: :desc)  }
end
