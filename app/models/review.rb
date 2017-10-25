class Review < ApplicationRecord
  belongs_to :user
  belongs_to :submission

  validates :user_id, presence: true
  validates :submission_id, presence: true
  validates :message, presence: true, length: { maximum: 2000 }
end
