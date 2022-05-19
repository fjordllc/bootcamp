# frozen_string_literal: true

require 'test_helper'

class API::CommentsTest < ActionDispatch::IntegrationTest
  fixtures :comments, :reports

  test 'GET /api/comments.json?commentable_id=12168338' do
    get api_comments_path(format: :json)
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    get api_comments_path(format: :json, commentable_id: 12_168_338),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request
  end
end
