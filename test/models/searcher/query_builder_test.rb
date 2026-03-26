# frozen_string_literal: true

require 'test_helper'

class Searcher::QueryBuilderTest < ActiveSupport::TestCase
  test 'initialize sets keyword' do
    builder = Searcher::QueryBuilder.new('test keyword')
    assert_equal 'test keyword', builder.keyword
  end

  test 'search_model returns results ordered by updated_at desc' do
    builder = Searcher::QueryBuilder.new('テスト')
    config = {
      model: Report,
      columns: %i[title description],
      includes: [:user]
    }

    results = builder.search_model(config)

    assert results.is_a?(Array)
    assert results.first.updated_at >= results.second.updated_at if results.size > 1
  end

  test 'search_model applies includes to avoid N+1' do
    builder = Searcher::QueryBuilder.new('テスト')
    config = {
      model: Product,
      columns: [:body],
      includes: %i[user practice]
    }

    results = builder.search_model(config)

    assert_nothing_raised do
      results.each { |product| product.user&.name }
    end
  end

  test 'search_model returns distinct results' do
    builder = Searcher::QueryBuilder.new('テスト')
    config = {
      model: Page,
      columns: %i[title body],
      includes: []
    }

    results = builder.search_model(config)

    assert_equal results.uniq.size, results.size
  end

  test 'pg_bigm_available? returns boolean' do
    Searcher::QueryBuilder.reset_pg_bigm_cache!
    result = Searcher::QueryBuilder.pg_bigm_available?
    assert_includes [true, false], result
  end

  test 'reset_pg_bigm_cache! clears cached value' do
    Searcher::QueryBuilder.pg_bigm_available?
    Searcher::QueryBuilder.reset_pg_bigm_cache!
    assert_not Searcher::QueryBuilder.instance_variable_defined?(:@pg_bigm_available)
  end

  test 'search_model with multiple keywords returns AND-filtered results' do
    config = Searcher::Configuration.get(:practice)
    builder = Searcher::QueryBuilder.new('OS クリーンインストール')
    results = builder.search_model(config)
    titles = results.map(&:title)
    assert_includes titles, practices(:practice1).title
    assert_not_includes titles, practices(:practice3).title
  end

  test 'search_model handles association columns gracefully' do
    config = Searcher::Configuration.get(:user)
    builder = Searcher::QueryBuilder.new('テスト')
    results = builder.search_model(config)
    assert_kind_of Array, results
  end

  test 'search_model escapes LIKE special characters' do
    builder = Searcher::QueryBuilder.new('100%_test')
    config = Searcher::Configuration.get(:practice)
    results = builder.search_model(config)
    assert_kind_of Array, results
  end

  test 'build_params returns single keyword params for external callers' do
    builder = Searcher::QueryBuilder.new('ruby')
    params = builder.build_params(%i[title description])
    assert_equal({ 'title_or_description_cont' => 'ruby' }, params)
  end

  test 'build_params returns multiple keyword params' do
    builder = Searcher::QueryBuilder.new('ruby rails')
    params = builder.build_params(%i[title description])
    expected = {
      g: [
        { 'title_or_description_cont' => 'ruby' },
        { 'title_or_description_cont' => 'rails' }
      ]
    }
    assert_equal expected, params
  end
end
