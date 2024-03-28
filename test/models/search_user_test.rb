# frozen_string_literal: true

require 'test_helper'

class SearchUserTest < ActiveSupport::TestCase
  include SearchUser

  test '検索文字が半角英文字2文字以下の時' do
    assert_nil validate_search_word('ki')
  end

  test '検索文字が半角英文字3文字以上の時' do
    assert_equal 'kim', validate_search_word('kim')
  end

  test '検索文字が全角英文字1文字以下の時' do
    assert_nil validate_search_word('き')
  end

  test '検索文字が全角英文字2文字以下の時' do
    assert_equal 'きむ', validate_search_word('きむ')
  end

  test '前後の空白は削除されること' do
    assert_equal 'kim', validate_search_word('  kim ')
  end
end
