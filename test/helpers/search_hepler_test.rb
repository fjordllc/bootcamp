# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  include SearchHelper

  setup do
    @user_komagata = users(:komagata)
    @user_muryou = users(:muryou)
    @comment = comments(:comment1)
    @unfinished_product_comment = comments(:comment88)
    @answer = answers(:answer1)
    @report = reports(:report1)
    @page = pages(:page1)
  end

  test 'searchable_url returns correct URL for Comment' do
    url = searchable_url(@comment)
    expected_url = "#{Rails.application.routes.url_helpers.polymorphic_path(@comment.commentable)}#comment_#{@comment.id}"
    assert_equal expected_url, url
  end

  test 'searchable_url returns correct URL for Answer' do
    url = searchable_url(@answer)
    expected_url = Rails.application.routes.url_helpers.question_path(@answer.question, anchor: "answer_#{@answer.id}")
    assert_equal expected_url, url
  end

  test 'searchable_url returns correct URL for Report' do
    url = searchable_url(@report)
    expected_url = Rails.application.routes.url_helpers.report_path(@report)
    assert_equal expected_url, url
  end

  test 'filtered_message returns summary for SearchResult' do
    searchable_result = SearchResult.new(@report, 'test', @user_komagata)
    filtered_message = filtered_message(searchable_result)
    assert_equal searchable_result.summary, filtered_message
  end

  test 'filtered_message returns body for Comment when policy allows' do
    searchable_message = filtered_message(@comment)
    assert_equal @comment.body, searchable_message
  end

  test 'filtered_message returns restricted message for Comment when policy restricts' do
    policy_mock = Minitest::Mock.new
    policy_mock.expect(:show?, false)

    stub :policy, policy_mock do
      searchable_message = filtered_message(@unfinished_product_comment)
      assert_equal '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。', searchable_message
    end

    policy_mock.verify
  end

  test 'created_user returns the correct user for SearchResult' do
    searchable_result = SearchResult.new(@report, 'test', @user_komagata)
    created_user = created_user(searchable_result)
    assert_equal @user_komagata, created_user
  end

  test 'created_user returns the correct user for Comment' do
    created_user = created_user(@comment)
    assert_equal @comment.user, created_user
  end
end
