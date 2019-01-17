# frozen_string_literal: true

class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :logo, blob: { content_type: :image, size_range: 0..10.megabytes }
  has_one_attached :logo
end
