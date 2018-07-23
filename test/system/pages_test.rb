require "application_system_test_case"

class PagesTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "GET /pages" do
    visit "/pages"
    assert_equal "Wiki | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET /pages/test1" do
    visit "/pages/test1"
    assert_equal "test1 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET multibyte name" do
    visit URI.escape("/pages/テスト")
    assert_equal "テスト | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET multibyte name edit page" do
    visit URI.escape("/pages/テスト/edit")
    assert_equal "ページ編集 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "title with half-width space" do
    target_page = pages(:page_1)
    visit edit_page_path(target_page)
    assert_equal edit_page_path(target_page), current_path
    fill_in "page[title]", with: "半角スペースを 含んでも 正常なページに 遷移する"
    click_button "内容を保存"
    assert_equal page_path(target_page.reload), current_path
  end
end
