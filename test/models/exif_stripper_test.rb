# frozen_string_literal: true

require 'test_helper'

class ExifStripperTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
  test '#call strips exif data from an uploaded image' do
    file_path = Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')
    original_image = MiniMagick::Image.open(file_path)

    assert_not_empty original_image.exif

    uploaded_file = fixture_file_upload(file_path, 'image/jpeg')
    processed_file = ExifStripper.call(uploaded_file)
    processed_image = MiniMagick::Image.read(processed_file[:io].read)

    assert_empty processed_image.exif
  end
end
