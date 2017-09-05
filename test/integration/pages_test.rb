require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  setup { login_user "komagata", "testtest" }

  test "GET /pages" do
    visit "/pages"
    assert_equal "Wiki | 256 INTERNS", title
  end

  test "GET /pages/test1" do
    visit "/pages/test1"
    assert_equal "test1 | 256 INTERNS", title
  end

  test "GET multibyte name" do
    visit URI.escape("/pages/テスト")
    assert_equal "テスト | 256 INTERNS", title
  end

  test "GET multibyte name edit page" do
    visit URI.escape("/pages/テスト/edit")
    assert_equal "ページ編集 | 256 INTERNS", title
  end
end
