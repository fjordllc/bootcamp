# frozen_string_literal: true

require "application_system_test_case"

class Notification::PagesTest < ApplicationSystemTestCase
  test "Only students and mentors are notified" do
    login_user "komagata", "testtest"
    visit "/pages"
    click_link "新規ページ"

    within(".form") do
      fill_in("page[title]", with: "DocsTest")
      fill_in("page[body]", with: "DocsTestBody")
    end
    click_button "内容を保存"

    logout
    login_user "hatsuno", "testtest"
    first(".test-bell").click
    assert_text "komagataさんがDocsにDocsTestを投稿しました。"

    logout
    login_user "machida", "testtest"
    first(".test-bell").click
    assert_text "komagataさんがDocsにDocsTestを投稿しました。"

    logout
    login_user "yameo", "testtest"
    visit "/notifications"
    assert_no_text "komagataさんがDocsにDocsTestを投稿しました。"
  end

  test "don't notify when page is WIP" do
    login_user "komagata", "testtest"
    visit "/pages"
    click_link "新規ページ"

    within(".form") do
      fill_in("page[title]", with: "DocsTest")
      fill_in("page[body]", with: "DocsTestBody")
    end
    click_button "WIP"

    logout
    login_user "hatsuno", "testtest"
    visit "/notifications"
    assert_no_text "komagataさんがDocsにDocsTestを投稿しました。"
  end
end
