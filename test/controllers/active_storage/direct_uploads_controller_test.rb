# frozen_string_literal: true

require 'test_helper'

class ActiveStorage::DirectUploadsControllerTest < ActionDispatch::IntegrationTest
  test 'direct upload requires login' do
    assert_no_difference('ActiveStorage::Blob.count') do
      post rails_direct_uploads_path, params: { blob: blob_params }, as: :json
      assert_response :unauthorized
    end
  end

  test 'logged in user can directly upload a file' do
    sign_in

    assert_difference('ActiveStorage::Blob.count') do
      post rails_direct_uploads_path, params: { blob: blob_params }, as: :json
      assert_response :success
    end

    upload = response.parsed_body
    blob = ActiveStorage::Blob.find_signed!(upload.fetch('signed_id'))
    assert_equal 'test.txt', blob.filename.to_s

    put upload.fetch('direct_upload').fetch('url'),
        params: 'test', headers: upload.fetch('direct_upload').fetch('headers')
    assert_response :no_content
    assert_equal 'test', blob.download
  ensure
    blob&.purge
  end

  test 'direct upload is rejected after logout' do
    sign_in
    get logout_path

    assert_no_difference('ActiveStorage::Blob.count') do
      post rails_direct_uploads_path, params: { blob: blob_params }, as: :json
      assert_response :unauthorized
    end
  end

  private

  def sign_in
    post user_sessions_path, params: { user: { login: users(:kimura).login_name, password: 'testtest' } }
    assert_redirected_to root_url
  end

  def blob_params
    {
      filename: 'test.txt',
      byte_size: 4,
      checksum: Digest::MD5.base64digest('test'),
      content_type: 'text/plain'
    }
  end
end
