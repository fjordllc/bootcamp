# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, attached: true

  def image=(attachable)
    MiniMagick::Image.new(attachable.tempfile.path).strip if attachable.respond_to?(:tempfile) && attachable.content_type&.start_with?('image/')
    super
  end
end
