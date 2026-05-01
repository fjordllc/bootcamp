# frozen_string_literal: true

require 'test_helper'

class API::TagsTest < ActionDispatch::IntegrationTest
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

  def authorization_header
    token = create_token('komagata', 'testtest')
    { 'Authorization' => "Bearer #{token}" }
  end
end
