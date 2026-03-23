# frozen_string_literal: true

require 'test_helper'

class BootcampSearchToolTest < ActiveSupport::TestCase
  setup do
    @tool = BootcampSearchTool.new
  end

  test 'search practices by keyword' do
    result = @tool.execute(query: 'テスト', category: 'practice')
    assert result.is_a?(String)
    assert_not_equal '検索結果が見つかりませんでした。別のキーワードで試してみてください。', result
    assert_includes result, 'プラクティス'
  end

  test 'search pages by keyword' do
    result = @tool.execute(query: 'テスト', category: 'page')
    assert result.is_a?(String)
  end

  test 'search all categories' do
    result = @tool.execute(query: 'テスト', category: 'all')
    assert result.is_a?(String)
  end

  test 'returns not found message for no results' do
    result = @tool.execute(query: 'xyzzy_nonexistent_term_12345')
    assert_equal '検索結果が見つかりませんでした。別のキーワードで試してみてください。', result
  end

  test 'handles empty query' do
    result = @tool.execute(query: '')
    assert_equal '検索結果が見つかりませんでした。別のキーワードで試してみてください。', result
  end

  test 'search with multiple keywords narrows results' do
    all_results = @tool.execute(query: 'テスト', category: 'practice')
    narrow_results = @tool.execute(query: 'テスト Rails', category: 'practice')
    # 複数キーワードはAND条件なので、結果が同じか少なくなるはず
    assert narrow_results.length <= all_results.length
  end

  test 'escapes LIKE special characters' do
    result = @tool.execute(query: '100%_test')
    assert result.is_a?(String)
  end

  test 'defaults to all category when invalid category given' do
    result = @tool.execute(query: 'テスト', category: 'invalid')
    assert result.is_a?(String)
  end

  test 'result contains URL paths' do
    result = @tool.execute(query: 'テスト', category: 'practice')
    # 結果があればURLが含まれる
    assert_includes result, '/practices/' if result.include?('プラクティス')
  end
end
