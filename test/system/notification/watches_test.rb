# frozen_string_literal: true

require "application_system_test_case"

class Notification::WatchesTest < ApplicationSystemTestCase
  test "日報作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現" do
    watches(:report1_watch_kimura)
    # コメントを投稿しても自動的にウォッチがONになる
    login_user "machida", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "いい日報ですね。")
    end
    click_button "コメントする"
    logout

    login_user "komagata", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "コメントありがとうございます。")
    end
    click_button "コメントする"
    logout

    login_user "kimura", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"

    login_user "machida", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{reports(:report_1).title} 】にコメントが投稿されました。"
  end

  test "質問作成者がコメントをした際、ウォッチ通知が飛ばないバグの再現" do
    watches(:question1_watch_kimura)
    # 質問に回答しても自動でウォッチがつく
    login_user "komagata", "testtest"
    visit "/questions/#{questions(:question_1).id}"
    within(".thread-comment-form__form") do
      fill_in("answer[description]", with: "Vimチュートリアルがおすすめです。")
    end
    click_button "コメントする"
    logout

    login_user "machida", "testtest"
    visit "/questions/#{questions(:question_1).id}"
    within(".thread-comment-form__form") do
      fill_in("answer[description]", with: "質問へのご回答ありがとうございます。")
    end
    click_button "コメントする"
    logout

    login_user "kimura", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{questions(:question_1).title} 】にコメントが投稿されました。"

    login_user "komagata", "testtest"
    first(".test-bell").click
    assert_text "あなたがウォッチしている【 #{questions(:question_1).title} 】にコメントが投稿されました。"
  end
end
