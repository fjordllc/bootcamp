# frozen_string_literal: true

require "application_system_test_case"

class QuestionsTest < ApplicationSystemTestCase
  setup do
    login_user "kimura", "testtest"
  end

  test "show listing unsolved questions" do
    visit questions_path
    assert_equal "未解決の質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing solved questions" do
    visit questions_path(solved: "true")
    assert_equal "解決済みの質問一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show a question" do
    question = questions(:question_8)
    visit question_path(question)
    assert_equal "テストの質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create a question" do
    visit new_question_path
    within "form[name=question]" do
      fill_in "question[title]", with: "テストの質問"
      fill_in "question[description]", with: "テストの質問です。"
      click_button "登録する"
    end
    assert_text "質問を作成しました。"
  end

  test "update a question" do
    question = questions(:question_8)
    visit edit_question_path(question)
    within "form[name=question]" do
      fill_in "question[title]", with: "テストの質問（修正）"
      fill_in "question[description]", with: "テストの質問です。（修正）"
      click_button "更新する"
    end
    assert_text "質問を更新しました。"
  end

  test "delete a question" do
    question = questions(:question_8)
    visit question_path(question)
    accept_confirm do
      find(".js-delete").click
    end
    assert_text "質問を削除しました。"
  end

  test "delete question with notification" do
    login_user "kimura", "testtest"
    visit "/questions"
    click_link "質問する"
    fill_in "question[title]", with: "タイトルtest"
    fill_in "question[description]", with: "内容test"

    click_button "登録する"
    assert_text "質問を作成しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_text "kimuraさんから質問がありました。"

    login_user "kimura", "testtest"
    visit "/questions"
    click_on "タイトルtest"
    accept_confirm do
      click_link "削除"
    end
    assert_text "質問を削除しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kimuraさんから質問がありました。"
  end
end
