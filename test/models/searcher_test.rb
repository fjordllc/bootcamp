# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  test "returns all types when filter argument isn't specified" do
    result = Searcher.search('テスト').map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
  end

  test "returns all types when filter argument is :all" do
    result = Searcher.search('テスト', filter: :all).map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
  end

  test "returns only report type when filter argument is :reports" do
    result = Searcher.search('テスト', filter: :reports).map(&:class)
    assert_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only page type when filter argument is :pages" do
    result = Searcher.search('テスト', filter: :pages).map(&:class)
    assert_not_includes(result, Report)
    assert_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only practice type when filter argument is :practices" do
    result = Searcher.search('テスト', filter: :practices).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only question type when filter argument is :questions" do
    result = Searcher.search('テスト', filter: :questions).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_includes(result, Question)
    assert_not_includes(result, Announcement)
  end

  test "returns only announcement type when filter argument is :announcements" do
    result = Searcher.search('テスト', filter: :announcements).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_includes(result, Announcement)
  end
end
