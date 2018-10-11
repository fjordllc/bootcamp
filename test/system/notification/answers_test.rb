require "application_system_test_case"

class Notification::AnswersTest < ApplicationSystemTestCase
  question = {
    title: "pull requestについて質問です",
    description: "kowabanaでPRしたら宜しいでしょうか？"
  }

  test "recieve a notification when I got my question's answer" do
    # 質問を作成
    login_user "yamada", "testtest"
    visit "/questions/new"

    within("#new_question") do
      fill_in("question[title]", with: question[:title])
      fill_in("question[description]", with: question[:description])
    end
    click_button "登録する"
    assert_text "質問を作成しました。"
    logout

    # 管理者が回答する
    login_user "komagata", "testtest"
    visit "/questions"

    assert_text question[:title]
    click_link question[:title]

    within("#new_answer") do
      fill_in("answer[description]", with: "kowabanaではなく自分のGitHubアカウントにリポジトリを作ってそこでやりましょう!")
    end
    click_button "コメントを投稿"
    logout

    # ユーザーがログインしたら通知があること
    login_user "yamada", "testtest"

    assert_selector ".header-notification-count", text: "1"
    assert_text "komagataさんから回答がありました。"
  end
end
