# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :image, attached: true

  def image=(attachable)
    if attachable.respond_to?(:tempfile)
      mime_type = Marcel::MimeType.for(attachable.tempfile)
      if %w[image/heic image/heif].include?(mime_type)
        attachable = convert_heic_to_webp(attachable)
      elsif mime_type.start_with?('image/')
        MiniMagick::Image.new(attachable.tempfile.path).strip
      end
    end
    super
  end

  private

  def convert_heic_to_webp(attachable)
    image = MiniMagick::Image.open(attachable.tempfile.path)
    image.format('webp') do |command|
      command.auto_orient
      command.strip
    end
    {
      io: StringIO.new(image.to_blob),
      filename: "#{File.basename(attachable.original_filename, '.*')}.webp",
      content_type: 'image/webp'
    }
  ensure
    image&.destroy!
  end
end
