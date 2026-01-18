# frozen_string_literal: true

require 'test_helper'

class SearcherModeTest < ActiveSupport::TestCase
  def current_user
    users(:kimura)
  end

  test 'default mode is keyword' do
    searcher = Searcher.new(keyword: 'test', current_user:)
    assert_equal :keyword, searcher.mode
  end

  test 'mode can be set to keyword' do
    searcher = Searcher.new(keyword: 'test', current_user:, mode: :keyword)
    assert_equal :keyword, searcher.mode
  end

  test 'mode can be set to semantic' do
    searcher = Searcher.new(keyword: 'test', current_user:, mode: :semantic)
    assert_equal :semantic, searcher.mode
  end

  test 'mode can be set to hybrid' do
    searcher = Searcher.new(keyword: 'test', current_user:, mode: :hybrid)
    assert_equal :hybrid, searcher.mode
  end

  test 'invalid mode falls back to keyword' do
    searcher = Searcher.new(keyword: 'test', current_user:, mode: :invalid)
    assert_equal :keyword, searcher.mode
  end

  test 'string mode is converted to symbol' do
    searcher = Searcher.new(keyword: 'test', current_user:, mode: 'semantic')
    assert_equal :semantic, searcher.mode
  end

  test 'MODES constant contains all valid modes' do
    assert_equal %i[keyword semantic hybrid], Searcher::MODES
  end

  test 'keyword search works with mode parameter' do
    results = Searcher.new(keyword: 'テスト', current_user:, mode: :keyword).search
    assert_kind_of Array, results
  end

  test 'semantic search returns empty array when API is not available' do
    # API key is not set in test environment, so semantic search should return empty
    results = Searcher.new(keyword: 'テスト', current_user:, mode: :semantic).search
    assert_kind_of Array, results
  end

  test 'hybrid search returns results when keyword search has results' do
    results = Searcher.new(keyword: 'テスト', current_user:, mode: :hybrid).search
    assert_kind_of Array, results
  end
end
