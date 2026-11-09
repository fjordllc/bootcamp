# frozen_string_literal: true

require 'test_helper'

class API::ImageControllerTest < ActionDispatch::IntegrationTest
  test 'uploads HEIC as WebP without exif data' do
    post user_sessions_path, params: { user: { login: 'hajime', password: 'testtest' } }
    image_path = Rails.root.join('test/fixtures/files/images/heic-sample-file.heic')

    assert_difference 'Image.count', 1 do
      post api_image_path(format: :json), params: { file: fixture_file_upload(image_path, 'image/heic') }
    end

    assert_response :created
    saved_image = Image.last.image
    assert_includes response.parsed_body['url'], saved_image.blob.signed_id
    assert_equal 'image/webp', saved_image.content_type
    assert_equal 'heic-sample-file.webp', saved_image.filename.to_s
    processed_image = MiniMagick::Image.read(saved_image.download)
    assert_equal 'WEBP', processed_image.type
    assert_equal [640, 426], processed_image.dimensions
    assert_empty processed_image.exif
  end

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

    saved_image = Image.last

    api_response = JSON.parse(response.body)
    returned_url = api_response['url']
    expected_blob = saved_image.image.blob
    assert_includes(returned_url, expected_blob.signed_id)

    processed_image = MiniMagick::Image.read(saved_image.image.download)
    assert_empty processed_image.exif
  end
end
