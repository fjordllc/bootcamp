# frozen_string_literal: true

require 'test_helper'

class API::QuestionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :questions

  setup do
    @question = questions(:question8)
    @path = api_question_path(@question.id, format: :json)
    @non_editable_user_login_name = User.where.not(login_name: @question.user.login_name)
                                        .find_by(admin: false).login_name
  end

  test 'GET api/questions.json' do
    get @path
    assert_response :unauthorized

    [@question.user.login_name, @non_editable_user_login_name].each do |name|
      token = create_token(name, 'testtest')
      get @path, headers: { 'Authorization' => "Bearer #{token}" }

      assert_response :ok
    end
  end

  test 'UPDATE api/questions.json' do
    patch @path, params: { question: { title: '認証失敗' } }
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    reset!
    assert_tags_updated(headers: { Authorization: "Bearer #{token}" })
  end

  %i[kimura hajime].each do |user|
    test "PATCH /api/questions.json with read scope for #{user} cannot change tags" do
      token = oauth_token(user, 'read')
      original_attributes = @question.attributes
      original_tags = @question.tag_list
      original_taggings = ActsAsTaggableOn::Tagging.order(:id).map(&:attributes)

      assert_no_difference('ActsAsTaggableOn::Tag.count') do
        patch @path, params: { question: tag_update_params }, headers: { Authorization: "Bearer #{token.token}" }
      end

      assert_response :forbidden
      assert_equal 'invalid_scope', response.parsed_body['error']
      assert_equal original_attributes, @question.reload.attributes
      assert_equal original_tags, @question.tag_list
      assert_equal original_taggings, ActsAsTaggableOn::Tagging.order(:id).map(&:attributes)
    end

    test "PATCH /api/questions.json with write scope for #{user} updates only tags" do
      token = oauth_token(user, 'read write')

      assert_tags_updated(headers: { Authorization: "Bearer #{token.token}" })
    end
  end

  test 'PATCH /api/questions.json with read scope rejects a missing question before lookup' do
    token = oauth_token(:hajime, 'read')

    patch api_question_path(999_999_999, format: :json),
          params: { question: tag_update_params },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'PATCH /api/questions.json with write scope returns not found for a missing question' do
    token = oauth_token(:hajime, 'read write')

    patch api_question_path(999_999_999, format: :json),
          params: { question: tag_update_params },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :not_found
  end

  test 'PATCH /api/questions.json with a nonowner session updates only tags' do
    sign_in(:hajime)

    assert_tags_updated
  end

  test 'GET /api/questions.json?user_id=253826460' do
    user = users(:hajime)
    get api_questions_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_questions_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  private

  def oauth_token(user, scopes)
    application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    Doorkeeper::AccessToken.create!(application:, resource_owner_id: users(user).id, scopes:)
  end

  def tag_update_params
    { tag_list: '新規タグ1,新規タグ2', title: '変更禁止', description: '変更禁止', user_id: users(:hajime).id }
  end

  def assert_tags_updated(headers: {})
    original_attributes = @question.attributes.slice('title', 'description', 'user_id')

    patch @path, headers:, params: { question: tag_update_params }

    assert_response :ok
    assert_equal %w[新規タグ1 新規タグ2], @question.reload.tag_list
    assert_equal original_attributes, @question.attributes.slice('title', 'description', 'user_id')
  end
end
