# frozen_string_literal: true

require 'test_helper'

class API::CommentsTest < ActionDispatch::IntegrationTest
  fixtures :comments, :products, :users

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

  test 'can create report comment with read, write scope' do
    report = reports(:report1)

    assert_difference('Comment.count') do
      post api_report_comments_url(report, format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New report comment' } }
      assert_response :created
    end

    comment = Comment.find(response.parsed_body['id'])
    assert_equal 'New report comment', comment.description
    assert_equal report, comment.commentable

    assert_equal comment.id, response.parsed_body['id']
    assert_equal 'New report comment', response.parsed_body['description']
    assert_equal 'Report', response.parsed_body['commentable_type']
    assert_equal report.id, response.parsed_body['commentable_id']
    assert_equal users(:komagata).id, response.parsed_body.dig('user', 'id')
  end

  test 'can not create report comment with read scope' do
    post api_report_comments_url(reports(:report1), format: :json),
         headers: { Authorization: "Bearer #{@read_token.token}" },
         params: { comment: { description: 'New report comment' } }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'returns not found when creating comment on missing report' do
    assert_no_difference('Comment.count') do
      post api_report_comments_url(0, format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New report comment' } }
    end

    assert_response :not_found
    assert_equal '日報が見つかりません。', response.parsed_body['message']
  end

  test 'returns validation error when creating blank report comment' do
    assert_no_difference('Comment.count') do
      post api_report_comments_url(reports(:report1), format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: '' } }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'description').present?
  end

  test 'returns validation error when creating report comment without comment parameter' do
    assert_no_difference('Comment.count') do
      post api_report_comments_url(reports(:report1), format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'description').present?
  end

  test 'returns bad request when creating comment without commentable_type' do
    assert_no_difference('Comment.count') do
      post api_comments_url(format: :json, commentable_id: @comment.commentable_id),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New comment' } }
    end

    assert_response :bad_request
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
      assert_response :ok
      assert_equal @comment.id, response.parsed_body['id']
    end
  end

  test 'mentor can update other user comment' do
    mentor_user = users(:mentormentaro)
    mentor_token = Doorkeeper::AccessToken.create!(
      application: @write_token.application,
      resource_owner_id: mentor_user.id,
      scopes: 'read write'
    )
    other_user_comment = comments(:comment1) # machida's comment

    patch api_comment_url(other_user_comment.id, format: :json),
          headers: { Authorization: "Bearer #{mentor_token.token}" },
          params: { comment: { description: 'Mentor updated this comment' } }
    assert_response :success
  end

  test 'admin can delete other user comment' do
    admin_user = users(:komagata)
    admin_token = Doorkeeper::AccessToken.create!(
      application: @write_token.application,
      resource_owner_id: admin_user.id,
      scopes: 'read write'
    )
    other_user_comment = comments(:comment3) # machida's comment

    assert_difference('Comment.count', -1) do
      delete api_comment_url(other_user_comment.id, format: :json),
             headers: { Authorization: "Bearer #{admin_token.token}" }
      assert_response :ok
      assert_equal other_user_comment.id, response.parsed_body['id']
    end
  end

  test 'regular user cannot update other user comment' do
    regular_user = users(:kimura)
    regular_token = Doorkeeper::AccessToken.create!(
      application: @write_token.application,
      resource_owner_id: regular_user.id,
      scopes: 'read write'
    )
    other_user_comment = comments(:comment1) # machida's comment

    patch api_comment_url(other_user_comment.id, format: :json),
          headers: { Authorization: "Bearer #{regular_token.token}" },
          params: { comment: { description: 'Trying to update' } }
    assert_response :not_found
  end

  test 'regular user cannot delete other user comment' do
    regular_user = users(:kimura)
    regular_token = Doorkeeper::AccessToken.create!(
      application: @write_token.application,
      resource_owner_id: regular_user.id,
      scopes: 'read write'
    )
    other_user_comment = comments(:comment1) # machida's comment

    assert_no_difference('Comment.count') do
      delete api_comment_url(other_user_comment.id, format: :json),
             headers: { Authorization: "Bearer #{regular_token.token}" }
      assert_response :not_found
    end
  end

  test 'can create product comment with read, write scope' do
    product = products(:product8)

    assert_difference('Comment.count') do
      post api_product_comments_url(product, format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New product comment' } }
      assert_response :created
    end

    comment = Comment.find(response.parsed_body['id'])
    assert_equal 'New product comment', comment.description
    assert_equal product, comment.commentable

    assert_equal comment.id, response.parsed_body['id']
    assert_equal 'New product comment', response.parsed_body['description']
    assert_equal 'Product', response.parsed_body['commentable_type']
    assert_equal product.id, response.parsed_body['commentable_id']
    assert_equal users(:komagata).id, response.parsed_body.dig('user', 'id')
    assert response.parsed_body['created_at'].present?
    assert response.parsed_body['updated_at'].present?
  end

  test 'can not create product comment with read scope' do
    post api_product_comments_url(products(:product8), format: :json),
         headers: { Authorization: "Bearer #{@read_token.token}" },
         params: { comment: { description: 'New product comment' } }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'returns not found when creating comment on missing product' do
    assert_no_difference('Comment.count') do
      post api_product_comments_url(0, format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: 'New product comment' } }
    end

    assert_response :not_found
    assert_equal '提出物が見つかりません。', response.parsed_body['message']
  end

  test 'returns validation error when creating blank product comment' do
    assert_no_difference('Comment.count') do
      post api_product_comments_url(products(:product8), format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { comment: { description: '' } }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'description').present?
  end
end
