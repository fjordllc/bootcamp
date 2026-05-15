# frozen_string_literal: true

class AuthoredBook < ApplicationRecord
  belongs_to :user
  has_one_attached :cover

  validates :cover, attached: false,
                    content_type: {
                      in: %w[image/png image/jpeg image/gif],
                      message: 'はPNG, JPG, GIF形式にしてください'
                    }

  scope :sorted, -> { order(created_at: :desc) }
end
