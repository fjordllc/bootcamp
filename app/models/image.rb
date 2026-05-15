# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  after_commit :strip_exif, on: :create

  private

  def strip_exif
    original_image = image
    copied_image = MiniMagick::Image.read(original_image.download)
    copied_image.strip

    ext = File.extname(original_image.filename.to_s)
    timestamp = Time.current.strftime('%Y%m%d%H%M%S%L')
    File.open(copied_image.path) do |file|
      original_image.attach(io: file, filename: "#{user.id}_#{timestamp}#{ext}")
    end
  rescue StandardError => e
    Rails.logger.error("Failed to strip EXIF: #{e.message}")
  ensure
    copied_image&.destroy!
  end
end
