# frozen_string_literal: true

require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing books" do
    visit books_path
    assert_text "書籍一覧"
  end

  test "search books" do
    visit books_path
    within("form[name=book_search]") do
      fill_in "word", with: "現場"
    end
    find("#book-search").click
    assert_text "'現場'の検索結果"
  end
end
