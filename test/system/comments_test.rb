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
    assert has_no_field?("comment[description]")
  end

  test "comment form found in /reports/:report_id" do
    visit report_path(users(:komagata).reports.first)
    assert has_field?("comment[description]")
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
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "post new comment with mention for report" do
    visit "/reports/#{reports(:report_1).id}"
    find(".js-markdown").set("login_nameの補完テスト: @koma\n")
    click_button "コメントする"
    assert_text "login_nameの補完テスト: @komagata"
    assert_selector :css, "a[href='/users/komagata']"
  end

  test "post new comment with emoji for report" do
    visit "/reports/#{reports(:report_1).id}"
    find(".js-markdown").set("絵文字の補完テスト: :bow: :cat\n")
    click_button "コメントする"
    assert_text "絵文字の補完テスト: 🙇 😺"
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
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end

  test "post new comment for announcement" do
    visit "/announcements/#{announcements(:announcement_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "test"
  end
end
