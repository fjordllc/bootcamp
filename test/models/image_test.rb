# frozen_string_literal: true

require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'remove exif data when image is updated' do
    image_path = Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')
    image = Image.create!(user: users(:hajime), image: Rack::Test::UploadedFile.new(image_path, 'image/jpeg'))

    image.update!(image: Rack::Test::UploadedFile.new(image_path, 'image/jpeg'))

    updated_image = MiniMagick::Image.read(image.image.download)
    assert_empty updated_image.exif
  end
end
