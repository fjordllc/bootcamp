# frozen_string_literal: true

require 'test_helper'

class SmartSearch::SemanticSearcherTest < ActiveSupport::TestCase
  def setup
    @searcher = SmartSearch::SemanticSearcher.new
  end

  test 'search returns empty array for blank query' do
    result = @searcher.search('')
    assert_empty result

    result = @searcher.search(nil)
    assert_empty result
  end

  test 'search returns empty array when API is not available' do
    original_key = ENV['OPENAI_API_KEY']
    ENV['OPENAI_API_KEY'] = nil

    searcher = SmartSearch::SemanticSearcher.new
    result = searcher.search('test query')

    assert_empty result
  ensure
    ENV['OPENAI_API_KEY'] = original_key
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
end
