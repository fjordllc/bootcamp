class Movie < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
end
