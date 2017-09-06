class Learning < ActiveRecord::Base
  as_enum :status, started: 0, complete: 1, not_complete: 2, task_checking: 3
  belongs_to :user, touch: true
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
    presence: true,
    uniqueness: { scope: :user_id }
end
