# frozen_string_literal: true

require 'test_helper'

class API::ImageTest < ActionDispatch::IntegrationTest
  test 'remove exif data from image when uploaded' do
    post user_sessions_path, params: {
      user: {
        login: 'hajime',
        password: 'testtest'
      }
    }

    image_path = Rails.root.join('test/fixtures/files/articles/ogp_images/test.jpg')
    original_image = MiniMagick::Image.open(image_path)

    assert_not_empty original_image.exif

    image_uploaded = fixture_file_upload(image_path, 'test/jpg')
    post api_image_path(format: :json), params: { file: image_uploaded }
    assert_response :created

    saved_image = Image.order(:created_at).last
    processed_image = MiniMagick::Image.read(saved_image.image.download)

    assert_empty processed_image.exif
  end
end
