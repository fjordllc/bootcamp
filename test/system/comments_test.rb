# frozen_string_literal: true

require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show all comments for reports of the target user" do
    visit polymorphic_path([users(:komagata), :comments])
    assert_equal 4, users(:komagata).comments.where(commentable_type: "Report").size
  end

  test "comment form not found in /users/:user_id/comments" do
    visit user_comments_path(users(:komagata))
    assert has_no_field?("new_comment[description]")
  end

  test "comment form found in /reports/:report_id" do
    visit report_path(users(:komagata).reports.first)
    assert has_field?("new_comment[description]")
  end

  test "comment form in reports/:id has comment tab and preview tab" do
    visit "/reports/#{reports(:report_3).id}"
    within(".thread-comment-form__tabs") do
      assert_text "コメント"
      assert_text "プレビュー"
    end
  end

  test "edit comment form has comment tab and preview tab" do
    visit "/reports/#{reports(:report_3).id}"
    within(".thread-comment:first-child") do
      click_button "編集"
      assert_text "コメント"
      assert_text "プレビュー"
    end
  end

  test "post new comment for report" do
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "post new comment with mention for report" do
    visit "/reports/#{reports(:report_1).id}"
    sleep 1
    find("#js-new-comment").set("login_nameの補完テスト: @koma\n")
    click_button "コメントする"

    assert_text "login_nameの補完テスト: @komagata"
    assert_selector :css, "a[href='/users/komagata']"
  end

  test "post new comment with emoji for report" do
    visit "/reports/#{reports(:report_1).id}"
    sleep 1
    find("#js-new-comment").set("絵文字の補完テスト: :cat\n")
    click_button "コメントする"

    assert_text "絵文字の補完テスト: 😺"
  end

  test "edit the comment for report" do
    visit "/reports/#{reports(:report_3).id}"
    within(".thread-comment:first-child") do
      click_button "編集"
      within(:css, ".thread-comment-form__form") do
        fill_in("comment[description]", with: "edit test")
      end
      click_button "保存する"
    end
    assert_text "edit test"
  end

  test "destroy the comment for report" do
    visit "/reports/#{reports(:report_3).id}"
    within(".thread-comment:first-child") do
      accept_alert do
        click_button("削除")
      end
    end
    assert_no_text "どういう教材がいいんでしょうかね？"
  end

  test "post new comment for product" do
    visit "/products/#{products(:product_1).id}"
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "post new comment for announcement" do
    visit "/announcements/#{announcements(:announcement_1).id}"
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "post new comment for page" do
    visit "/pages/#{pages(:page_1).id}"
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "comment tab is active after a comment has been posted" do
    visit "/reports/#{reports(:report_3).id}"
    assert_equal "コメント", find(".thread-comment-form__tab.is-active").text
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    find(".thread-comment-form__tab", text: "プレビュー").click
    assert_equal "プレビュー", find(".thread-comment-form__tab.is-active").text
    click_button "コメントする"
    assert_text "test"
    assert_equal "コメント", find(".thread-comment-form__tab.is-active").text
  end

  test "prevent double submit" do
    visit report_path(users(:komagata).reports.first)
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    assert_raises Selenium::WebDriver::Error::ElementClickInterceptedError do
      find("#js-shortcut-post-comment", text: "コメントする").click.click
    end
  end

  test "submit_button is enabled after a post is done" do
    visit report_path(users(:komagata).reports.first)
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
    within(".thread-comment-form__form") do
      fill_in("new_comment[description]", with: "testtest")
    end
    click_button "コメントする"
    assert_text "testtest"
  end

  test "comment url is copied when click its updated_time" do
    visit "/reports/#{reports(:report_1).id}"
    first(:css, ".thread-comment__created-at").click
    # クリップボードを直接読み取る方法がないので、未入力のテキストエリアを経由してクリップボードの値を読み取っている
    # また、Ctrl-Vではペーストできなかったので、かわりにShift-Insertをショートカットキーとして使っている
    # 参考 https://stackoverflow.com/a/57955123/1058763
    find("#js-new-comment").send_keys [:shift, :insert]
    clip_text = find("#js-new-comment").value
    assert_equal current_url + "#comment_#{comments(:comment_1).id}", clip_text
  end
end
