# frozen_string_literal: true

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
    visit "/pages/#{id}/edit"
    assert_equal "ページ編集 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "title with half-width space" do
    target_page = pages(:page_1)
    visit edit_page_path(target_page)
    assert_equal edit_page_path(target_page), current_path
    fill_in "page[title]", with: "半角スペースを 含んでも 正常なページに 遷移する"
    click_button "内容を保存"
    assert_equal page_path(target_page.reload), current_path
    assert_text "ページを更新しました"
  end

  test "add new page" do
    visit new_page_path
    assert_equal new_page_path, current_path
    fill_in "page[title]", with: "新規ページを作成する"
    fill_in "page[body]", with: "新規ページを作成する本文です"
    click_button "内容を保存"
    assert_text "ページを作成しました"
  end

  test "Show pagination" do
    Page.delete_all
    21.times do |n|
      Page.create(title: "test#{n}", body: "test#{n}")
    end
    visit "/pages"
    assert_selector "nav.pagination", count: 2
  end

  test "Show pagination in /users/:id/comments" do
    user   = users(:komagata)
    report = reports(:report_4)
    user.comments.delete_all
    100.times do |i|
      user.comments.create(description: "comment #{i + 1}", commentable_id: report.id, commentable_type: "Report")
    end

    visit user_comments_path([user], page: 1)
    assert_selector "span.thread-comments-container__title-count", text: "（1 〜 25 件を表示）"
    assert_selector "nav.pagination", count: 1
    assert_equal 25, user.comments.page(1).size

    visit user_comments_path([users(:komagata)], page: 3)
    assert_equal 25, user.comments.page(3).size
  end

  test "Show pagination in /users/:id/reports" do
    user = users(:komagata)
    d    = Time.mktime(2015, 1, 1, 0, 0, 0)
    user.reports.destroy_all
    100.times do |i|
      user.reports.create(title: "Report #{i + 1}", description: "description...", reported_on: d, created_at: d, updated_at: d)
      d = d + 1.day
    end
    visit user_reports_path([user], page: 1)
    assert_selector "span.thread-comments-container__title-count", text: "（1 〜 25 件を表示）"
    assert_selector "nav.pagination", count: 1
    assert_equal 25, user.reports.page(1).size

    visit user_reports_path([users(:komagata)], page: 3)
    assert_equal 25, user.reports.page(3).size
  end

  test "If you click the link of a nonexistent page, it will not transition to wiki create page" do
    id = pages(:page_3).id
    visit "/pages/#{id}"

    click_link "存在しないページ"

    assert_no_text "ページ作成"
  end

  test "Comment form not found in /users/:user_id/comments" do
    user = users(:yamada)
    visit user_comments_path(user)
    assert_equal true, has_no_field?("comment[description]")
  end

  test "Comment form found in /reports/:report_id" do
    user = users(:yamada)
    visit report_path(user.reports.first)
    assert_equal true, has_field?("comment[description]")
  end
end
