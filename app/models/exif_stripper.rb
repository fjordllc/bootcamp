# frozen_string_literal: true

class ExifStripper
  def self.call(uploaded_file)
    image = MiniMagick::Image.read(uploaded_file.tempfile)
    image.strip

    {
      io: StringIO.new(image.to_blob),
      filename: uploaded_file.original_filename.to_s,
      content_type: uploaded_file.content_type
    }
  end
end
