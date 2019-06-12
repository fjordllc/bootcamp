# frozen_string_literal: true

require "application_system_test_case"

class Notification::WatchesTest < ApplicationSystemTestCase
  test "report watcher receive a notification" do
    watches(:report1_watch_kimura)

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

  test "日報にコメントしたら自動でウォッチがつくこと" do
    # コメントを投稿しても自動的にウォッチがONになる
    login_user "machida", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "いい日報ですね。")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"
    logout

    login_user "komagata", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "ありがとうございます。")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"
    logout

    login_user "machida", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"
  end

  test "question watchers can receive watch notification" do
    watches(:question1_watch_kimura)
    # 質問に回答しても自動でウォッチがつく
    login_user "komagata", "testtest"
    visit "/questions/#{questions(:question_1).id}"
    within(".thread-comment-form__form") do
      fill_in("answer[description]", with: "Vimチュートリアルがおすすめです。")
    end
    click_button "コメントする"
    assert_text "回答を作成しました。"
    logout

    login_user "machida", "testtest"
    visit "/questions/#{questions(:question_1).id}"
    within(".thread-comment-form__form") do
      fill_in("answer[description]", with: "ありがとうございます。")
    end
    click_button "コメントする"
    assert_text "回答を作成しました。"
    logout

    login_user "kimura", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{questions(:question_1).title} 】にコメントが投稿されました。"

    login_user "komagata", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{questions(:question_1).title} 】にコメントが投稿されました。"
  end
end
