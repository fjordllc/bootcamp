class TaskRequest < ApplicationRecord
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true, uniqueness: { scope: :practice_id }
  validates :practice_id, presence: true
  validates :passed, inclusion: { in: [true, false] }
  validates :content, presence: true, length: { minimum: 5, maximum: 2000 }
end
