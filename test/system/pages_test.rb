require "application_system_test_case"

class PagesTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "GET /pages" do
    visit "/pages"
    assert_equal "Wiki | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    assert_no_selector "nav.pagination"
  end

  test "show page" do
    id = pages(:page_1).id
    visit "/pages/#{id}"
    assert_equal "test1 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show edit page" do
    id = pages(:page_2).id
    visit URI.escape("/pages/#{id}/edit")
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


  test "Show pagination" do
    Page.delete_all
    21.times do |n|
      Page.create(title: "test#{n}", body: "test#{n}")
    end
    visit "/pages"
    assert_selector "nav.pagination", count: 2
  end
end
