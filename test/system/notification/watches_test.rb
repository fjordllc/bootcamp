# frozen_string_literal: true

require "application_system_test_case"

class Notification::WatchesTest < ApplicationSystemTestCase
  setup do
    watches(:report1_watch_kimura)
    watches(:product1_watch_kimura)
    watches(:question1_watch_kimura)
  end

  test "report watcher receive a notification" do
    login_user "machida", "testtest"
    visit "/reports/#{reports(:report_1).id}"

    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "いい日報ですね。")
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
      fill_in("comment[description]", with: "いい提出物ですね。")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"

    logout
    login_user "kimura", "testtest"

    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{products(:product_1).title} 】にコメントが投稿されました。"
  end

  test "question watcher receive a notification" do
    login_user "sotugyou", "testtest"
    visit "/questions/#{questions(:question_1).id}"

    within(".thread-comment-form__form") do
      fill_in("answer[description]", with: "vimチュートリアルがおすすめだよ。")
    end
    click_button "コメントする"
    assert_text "回答を作成しました。"

    logout
    login_user "kimura", "testtest"

    visit "/questions/#{questions(:question_1).id}"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{questions(:question_1).title} 】にコメントが投稿されました。"
  end
end
