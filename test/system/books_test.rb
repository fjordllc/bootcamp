# frozen_string_literal: true

require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "check book list" do
    visit books_path
    assert_text "書籍一覧"
  end
end
