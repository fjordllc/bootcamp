# frozen_string_literal: true

require "application_system_test_case"

class Notification::WatchesTest < ApplicationSystemTestCase
  setup do
    watches(:report1_watch_kimura)
    watches(:product1_watch_kimura)
  end

  test "report watcher receive a notification" do
    login_user "machida", "testtest"
    visit "/reports/#{reports(:report_1).id}"

    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"

    logout
    login_user "kimura", "testtest"

    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"
  end

  test "product watcher receive a notification" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"

    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"

    logout
    login_user "kimura", "testtest"

    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{products(:product_1).title} 】にコメントが投稿されました。"
  end
end
