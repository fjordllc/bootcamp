# frozen_string_literal: true

require "application_system_test_case"

class SearchablesTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "search All " do
    within("form[name=search]") do
      select "すべて"
      fill_in "word", with: "テスト"
    end
    find("#test-search").click
    assert_text "テストの日報"
    assert_text "Docsページ"
    assert_text "Unityでのテスト"
    assert_text "テストの質問1"
    assert_text "テストのお知らせ"
  end

  test "search reports " do
    within("form[name=search]") do
      select "日報"
      fill_in "word", with: "テスト"
    end
    find("#test-search").click
    assert_text "テストの日報"
    assert_no_text "Docsページ"
    assert_no_text "Unityでのテスト"
    assert_no_text "テストの質問1"
    assert_no_text "テストのお知らせ"
  end

  test "show user name and created time" do
    within("form[name=search]") do
      select "日報"
      fill_in "word", with: "テストの日報"
    end
    find("#test-search").click
    assert_text "yamada"
    assert_css ".thread-list-item-meta__created-at"
  end
end
