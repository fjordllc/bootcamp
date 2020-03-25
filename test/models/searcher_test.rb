# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  test "returns all types when document_type argument isn't specified" do
    result = Searcher.search("テスト").map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
  end

  test "returns all types when document_type argument is :all" do
    result = Searcher.search("テスト", document_type: :all).map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
  end

  test "returns only report type when document_type argument is :reports" do
    result = Searcher.search("テスト", document_type: :reports).map(&:class)
    assert_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only page type when document_type argument is :pages" do
    result = Searcher.search("テスト", document_type: :pages).map(&:class)
    assert_not_includes(result, Report)
    assert_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only practice type when document_type argument is :practices" do
    result = Searcher.search("テスト", document_type: :practices).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only question type when document_type argument is :questions" do
    result = Searcher.search("テスト", document_type: :questions).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only announcement type when document_type argument is :announcements" do
    result = Searcher.search("テスト", document_type: :announcements).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_includes(result, Announcement)
  end

  test "sort search results in descending order of creation date" do
    result = Searcher.search("検索結果確認用", document_type: :reports)
    assert_equal [reports(:report_12), reports(:report_14), reports(:report_13)], result
  end
end
