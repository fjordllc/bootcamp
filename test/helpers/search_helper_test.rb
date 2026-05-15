# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  include SearchHelper

  setup do
    @user_komagata = users(:komagata)
    @user_muryou = users(:muryou)
    @comment = comments(:comment1)
    @unfinished_product_comment = comments(:comment87)
    @answer = answers(:answer1)
    @report = reports(:report1)
    @page = pages(:page1)
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

  test 'search_summary, comment = word' do
    comment = '検索ワード'
    word = '検索ワード'
    resource = Minitest::Mock.new
    resource.expect(:is_a?, false, [Comment])
    resource.expect(:search_content, comment)

    assert_equal '検索ワード', search_summary(resource, word)
    resource.verify
  end

  test 'search_summary, word is ""' do
    comment = '0987654321検索ワード1234567890'
    word = ''
    resource = Minitest::Mock.new
    resource.expect(:is_a?, false, [Comment])
    resource.expect(:search_content, comment)

    result = search_summary(resource, word)
    assert_equal comment.length, result.length
    resource.verify
  end

  test 'search_summary, word is space' do
    comment = '0987654321検索ワード1234567890'
    word = ' '
    resource = Minitest::Mock.new
    resource.expect(:is_a?, false, [Comment])
    resource.expect(:search_content, comment)

    result = search_summary(resource, word)
    assert_equal comment.length, result.length
    resource.verify
  end

  test 'search_summary, word is multiple' do
    comment = '09876543210987654321098765432109876543210987654321検索ワード検索単語キーワード12345678901234567890'
    word = 'キーワード　検索ワード　単語　'
    resource = Minitest::Mock.new
    resource.expect(:is_a?, false, [Comment])
    resource.expect(:search_content, comment)

    result = search_summary(resource, word)
    assert_includes result, '検索ワード'
    resource.verify
  end

  test 'regexp in search_summary' do
    comment = 'テスト! " # $ \' % & ( ) = ~ | - ^ ¥ ` { @ [ + * } ; : ] < > ? _ , . / 　テスト'
    word = '% テスト'
    resource = Minitest::Mock.new
    resource.expect(:is_a?, false, [Comment])
    resource.expect(:search_content, comment)

    result = search_summary(resource, word)
    assert_includes result, 'テスト'
    resource.verify
  end
end
