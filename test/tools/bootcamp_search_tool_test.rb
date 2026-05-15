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
    # 単一キーワードの結果数
    all_result = @tool.execute(query: 'テスト', category: 'practice')
    all_count = all_result.scan(/\*\*\[プラクティス\]/).size

    # 複数キーワード（AND条件）の結果数は同じか少なくなるはず
    narrow_result = @tool.execute(query: 'テスト Rails', category: 'practice')
    narrow_count = narrow_result.scan(/\*\*\[プラクティス\]/).size

    assert narrow_count <= all_count
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
    # フィクスチャに「テスト」を含むプラクティスが存在する前提
    assert_includes result, 'プラクティス', 'テスト用プラクティスが見つかりません'
    assert_includes result, '/practices/', '検索結果にURLパスが含まれていません'
  end
end
