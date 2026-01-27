# frozen_string_literal: true

require 'test_helper'

class SmartSearch::SemanticSearcherTest < ActiveSupport::TestCase
  def setup
    @original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil
    @searcher = SmartSearch::SemanticSearcher.new
  end

  def teardown
    ENV['OPEN_AI_ACCESS_TOKEN'] = @original_key
  end

  test 'search returns empty array for blank query' do
    result = @searcher.search('')
    assert_empty result

    result = @searcher.search(nil)
    assert_empty result
  end

  test 'search returns empty array when API is not available' do
    result = @searcher.search('test query')
    assert_empty result
  end

  test 'search accepts document_type parameter' do
    result = @searcher.search('test', document_type: :practice)
    assert_kind_of Array, result
  end

  test 'search accepts limit parameter' do
    result = @searcher.search('test', limit: 5)
    assert_kind_of Array, result
  end

  test 'search returns array on error' do
    result = @searcher.search('test')
    assert_kind_of Array, result
  end

  test 'search handles nil document_type' do
    result = @searcher.search('test', document_type: nil)
    assert_kind_of Array, result
  end

  test 'search handles invalid limit' do
    result = @searcher.search('test', limit: -1)
    assert_kind_of Array, result

    result = @searcher.search('test', limit: nil)
    assert_kind_of Array, result
  end
end
