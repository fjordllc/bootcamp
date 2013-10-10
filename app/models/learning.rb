class Learning < ActiveRecord::Base
  as_enum :status, started: 0, complete: 1
  belongs_to :user
  belongs_to :practice

  validates :user_id, presence: true
  validates :practice_id,
    presence: true,
    uniqueness: { scope: :user_id }
end
