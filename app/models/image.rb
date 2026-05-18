# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, attached: true

  attr_accessor :file

  def strip_exif!
    return if file.blank?

    uploaded_file = file
    original_image = MiniMagick::Image.read(uploaded_file.tempfile)
    original_image.strip

    blob = {
      io: StringIO.new(original_image.to_blob),
      filename: uploaded_file.original_filename.to_s,
      content_type: uploaded_file.content_type
    }

    image.attach(blob)
  end
end
