class Movie < ApplicationRecord
  include Taggable

  belongs_to :user
  belongs_to :practice, optional: true
  has_one_attached :thumbnail
  has_one_attached :movie_data

  validates :user, presence: true
  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
end
