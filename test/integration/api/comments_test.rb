# frozen_string_literal: true

require 'test_helper'

class API::CommentsTest < ActionDispatch::IntegrationTest
  fixtures :comments, :users

  def setup
    user = users(:komagata)
    @comment = comments(:comment1)
    application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @read_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    @write_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: user.id,
      scopes: 'read write'
    )
  end

  test 'GET /api/comments.json?commentable_id=12168338' do
    get api_comments_path(format: :json)
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    get api_comments_path(format: :json, commentable_id: 12_168_338),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request
  end

  # Scope: read
  test 'can get comment list with read scope' do
    get api_comments_url(format: :json, commentable_type: 'Report', commentable_id: @comment.commentable_id),
        headers: { Authorization: "Bearer #{@read_token.token}" }
    assert_response :success
  end

  test 'can not create comment with read scope' do
    post api_comments_url(format: :json, commentable_type: 'Report', commentable_id: @comment.commentable_id),
         headers: { Authorization: "Bearer #{@read_token.token}" },
         params: { comment: { description: 'New comment' } }
    assert_response :forbidden
  end

  test 'can not update comment with read scope' do
    patch api_comment_url(@comment.id, format: :json),
          headers: { Authorization: "Bearer #{@read_token.token}" },
          params: { description: 'Updated comment' }
    assert_response :forbidden
  end

  test 'can not delete comment with read scope' do
    delete api_comment_url(@comment.id, format: :json),
           headers: { Authorization: "Bearer #{@read_token.token}" }
    assert_response :forbidden
  end

  # Scope: read, write
  test 'can get comment list with read, write scope' do
    get api_comments_url(format: :json, commentable_type: 'Report', commentable_id: @comment.commentable_id),
        headers: { Authorization: "Bearer #{@write_token.token}" }
    assert_response :success
  end

  test 'can create comment with read, write scope' do
    assert_difference('Comment.count') do
      post api_comments_url(commentable_type: 'Report', commentable_id: @comment.commentable_id),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New comment' } }
      assert_response :created
    end
  end

  test 'can update comment with read, write scope' do
    patch api_comment_url(@comment.id, format: :json),
          headers: { Authorization: "Bearer #{@write_token.token}" },
          params: { comment: { description: 'Updated comment' } }
    assert_response :success
  end

  test 'can delete comment with read, write scope' do
    assert_difference('Comment.count', -1) do
      delete api_comment_url(@comment.id, format: :json),
             headers: { Authorization: "Bearer #{@write_token.token}" }
      assert_response :no_content
    end
  end
end
