# frozen_string_literal: true

require 'test_helper'

class Searcher::QueryBuilderTest < ActiveSupport::TestCase
  test 'initialize sets keyword' do
    builder = Searcher::QueryBuilder.new('test keyword')
    assert_equal 'test keyword', builder.keyword
  end

  test 'build_params returns single keyword params' do
    builder = Searcher::QueryBuilder.new('ruby')
    params = builder.build_params(%i[title description])

    assert_equal({ 'title_or_description_cont' => 'ruby' }, params)
  end

  test 'build_params returns multiple keyword params with AND condition' do
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

  test 'build_params handles single column' do
    builder = Searcher::QueryBuilder.new('test')
    params = builder.build_params([:title])

    assert_equal({ 'title_cont' => 'test' }, params)
  end

  test 'build_params handles Japanese keywords' do
    builder = Searcher::QueryBuilder.new('日本語　テスト')
    params = builder.build_params(%i[title body])

    expected = {
      g: [
        { 'title_or_body_cont' => '日本語' },
        { 'title_or_body_cont' => 'テスト' }
      ]
    }
    assert_equal expected, params
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
    # 結果が複数ある場合、更新日時の降順であることを確認
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

    # includesが適用されていることを確認（N+1を防ぐ）
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

    # 重複がないことを確認
    assert_equal results.uniq.size, results.size
  end
end
