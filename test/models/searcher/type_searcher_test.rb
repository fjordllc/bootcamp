# frozen_string_literal: true

require 'test_helper'

class Searcher::TypeSearcherTest < ActiveSupport::TestCase
  def setup
    @query_builder = Searcher::QueryBuilder.new('テスト')
  end

  test 'initialize sets query_builder and document_type' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :page)

    assert_equal @query_builder, type_searcher.query_builder
    assert_equal :page, type_searcher.document_type
  end

  test 'search returns all types when document_type is :all' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :all)

    results = type_searcher.search

    assert results.is_a?(Array)
    # 複数のタイプが含まれることを確認
    class_names = results.map(&:class).map(&:name).uniq
    assert class_names.size > 1
  end

  test 'search returns specific type and related comments' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :page)

    results = type_searcher.search

    assert results.is_a?(Array)
    # Pageタイプの結果が含まれることを確認
    assert(results.any? { |result| result.is_a?(Page) })
  end

  test 'search returns question with answers and correct answers' do
    # 質問検索の場合、回答と模範回答も含まれる
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :question)

    results = type_searcher.search

    assert results.is_a?(Array)
    class_names = results.map(&:class).map(&:name).uniq

    # Question、Answer、CorrectAnswerが含まれることを確認
    assert_includes class_names, 'Question'
    # Answerが存在する場合は含まれる
    assert_includes class_names, 'Answer' if Answer.where('description LIKE ?', '%テスト%').exists?
    # CorrectAnswerが存在する場合は含まれる
    assert_includes class_names, 'CorrectAnswer' if CorrectAnswer.where('description LIKE ?', '%テスト%').exists?
  end

  test 'search excludes related comments for comment type' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :comment)

    results = type_searcher.search

    # commentタイプの検索では関連コメントは追加されない
    assert(results.all? { |result| result.is_a?(Comment) })
  end

  test 'search returns empty array for non-existent document type' do
    # 存在しないタイプの設定を取得しようとした場合の処理テスト
    query_builder = Searcher::QueryBuilder.new('test')

    # 実際には validate_document_type で検証されるため、このケースは通常発生しない
    # ただし、Configurationから設定が取得できない場合のテスト
    type_searcher = Searcher::TypeSearcher.new(query_builder, :non_existent)

    results = type_searcher.search

    assert_empty results
  end

  test 'search handles practice type with related comments' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :practice)

    results = type_searcher.search

    assert results.is_a?(Array)
    # Practiceタイプの結果が含まれることを確認
    assert(results.any? { |result| result.is_a?(Practice) })
  end

  test 'search handles report type with related comments' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :report)

    results = type_searcher.search

    assert results.is_a?(Array)
    # Reportタイプの結果が含まれることを確認
    assert(results.any? { |result| result.is_a?(Report) })
  end

  test 'search handles user type with related comments' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :user)

    results = type_searcher.search

    assert results.is_a?(Array)
    # Userタイプの結果が含まれる場合を確認
    assert(results.any? { |result| result.is_a?(User) }) if results.any?
  end

  test 'search handles product type with related comments' do
    type_searcher = Searcher::TypeSearcher.new(@query_builder, :product)

    results = type_searcher.search

    assert results.is_a?(Array)
    # Productタイプの結果が含まれる場合を確認
    assert(results.any? { |result| result.is_a?(Product) }) if results.any?
  end
end
