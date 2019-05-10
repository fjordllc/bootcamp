# frozen_string_literal: true

class Work < ApplicationRecord
  belongs_to :user
  has_one_attached :thumbnail

  validates :user, presence: true
  validates :title, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :description, presence: true
  validates :repository, presence: true
  validates :thumbnail, blob: { content_type: :image, size_range: 0..10.megabytes }
end
