# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, attached: true

  def image=(attachable)
    if attachable.respond_to?(:tempfile) && Marcel::MimeType.for(attachable.tempfile).start_with?('image/')
      MiniMagick::Image.new(attachable.tempfile.path).strip
    end
    super
  end
end
