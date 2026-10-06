# frozen_string_literal: true

require 'test_helper'

class API::TagsTest < ActionDispatch::IntegrationTest
  test 'lists user tags without authentication for registration autocomplete' do
    get api_tags_path(format: :json), params: { taggable_type: 'User' }

    assert_response :ok
    assert_includes response.parsed_body, { 'id' => acts_as_taggable_on_tags(:beginner).id, 'value' => '初心者' }
  end

  test 'rejects an unauthenticated update before looking up a missing tag' do
    patch api_tag_path(-1, format: :json), params: { tag: { name: '上級者' } }

    assert_response :unauthorized
  end

  %i[rename merge].each do |operation|
    test "rejects unauthenticated tag #{operation} without changing tags or taggings" do
      assert_rejected_tag_mutation(operation, :unauthorized)
    end

    %i[kimura advijirou].each do |user|
      test "rejects tag #{operation} by #{user} with JWT authentication" do
        assert_rejected_tag_mutation(operation, :forbidden, authorization_header(user.to_s))
      end

      test "rejects tag #{operation} by #{user} with session authentication" do
        sign_in(user)

        assert_rejected_tag_mutation(operation, :forbidden)
      end

      test "rejects tag #{operation} by #{user} with OAuth write scope" do
        assert_rejected_tag_mutation(operation, :forbidden, oauth_header(user, 'read write'))
      end
    end

    %i[adminonly mentormentaro].each do |user|
      test "allows tag #{operation} by #{user} with JWT authentication" do
        assert_allowed_tag_mutation(operation, authorization_header(user.to_s))
      end

      test "allows tag #{operation} by #{user} with session authentication" do
        sign_in(user)

        assert_allowed_tag_mutation(operation)
      end

      test "rejects tag #{operation} by #{user} with OAuth read scope" do
        assert_rejected_tag_mutation(operation, :forbidden, oauth_header(user, 'read'))
      end

      test "allows tag #{operation} by #{user} with OAuth write scope" do
        assert_allowed_tag_mutation(operation, oauth_header(user, 'read write'))
      end
    end
  end

  test 'updates page tags through API' do
    page = pages(:page1)

    patch api_page_path(page, format: :json),
          params: { page: { tag_list: '追加タグ' } },
          headers: authorization_header

    assert_response :ok
    assert_equal ['追加タグ'], page.reload.tag_list
  end

  test 'updates question tags through API' do
    question = questions(:question2)

    patch api_question_path(question, format: :json),
          params: { question: { tag_list: '追加タグ' } },
          headers: authorization_header

    assert_response :ok
    assert_equal ['追加タグ'], question.reload.tag_list
  end

  test 'renames an existing tag to an unused name across taggings' do
    tag = acts_as_taggable_on_tags('beginner')
    new_tag_name = '上級者'

    patch api_tag_path(tag, format: :json),
          params: { tag: { name: new_tag_name } },
          headers: authorization_header

    assert_response :ok
    assert_empty Question.tagged_with(tag.name)
    assert_equal [questions(:question3)], Question.tagged_with(new_tag_name)
    assert_empty User.active_tagged_with(tag.name)
    assert_equal [users(:kimura)], User.active_tagged_with(new_tag_name)
    assert_empty Page.tagged_with(tag.name)
    assert_equal [pages(:page1)], Page.tagged_with(new_tag_name)
  end

  private

  def authorization_header(login_name = 'komagata')
    token = create_token(login_name, 'testtest')
    { 'Authorization' => "Bearer #{token}" }
  end

  def oauth_header(user, scopes)
    application = Doorkeeper::Application.create!(
      name: 'Tag authorization test',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: users(user).id, scopes:)
    { 'Authorization' => "Bearer #{token.token}" }
  end

  def assert_rejected_tag_mutation(operation, status, headers = {})
    tag = acts_as_taggable_on_tags(:beginner)
    name = operation == :merge ? acts_as_taggable_on_tags(:intermediate).name : '上級者'

    assert_no_changes -> { tag_state } do
      patch api_tag_path(tag, format: :json), params: { tag: { name: } }, headers: headers
    end

    assert_response status
  end

  def tag_state
    [
      ActsAsTaggableOn::Tag.order(:id).pluck(:id, :name),
      ActsAsTaggableOn::Tagging.order(:id).pluck(:id, :tag_id, :taggable_type, :taggable_id, :context)
    ]
  end

  def assert_allowed_tag_mutation(operation, headers = {})
    tag = acts_as_taggable_on_tags(:beginner)
    target = acts_as_taggable_on_tags(:intermediate)
    name = operation == :merge ? target.name : '上級者'
    expected_taggings = tagging_associations(tag)
    expected_taggings = (expected_taggings + tagging_associations(target)).uniq.sort if operation == :merge

    patch api_tag_path(tag, format: :json), params: { tag: { name: } }, headers: headers

    assert_response :ok
    if operation == :merge
      assert_empty tagging_associations(tag)
      assert_equal expected_taggings, tagging_associations(target)
    else
      assert_equal name, tag.reload.name
      assert_equal expected_taggings, tagging_associations(tag)
    end
  end

  def tagging_associations(tag)
    ActsAsTaggableOn::Tagging.where(tag_id: tag.id).pluck(:taggable_type, :taggable_id, :context).sort
  end
end
