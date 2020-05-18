# frozen_string_literal: true

require "application_system_test_case"

class AnswersTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "admin can edit and delete any questions" do
    visit "/questions/#{questions(:question_1).id}"
    answer_by_user = page.all(".thread-comment")[1]
    within answer_by_user do
      assert_text "内容修正"
      assert_text "削除"
    end
  end

  test "admin can resolve user's question" do
    visit "/questions/#{questions(:question_2).id}"
    assert_text "解決にする"
    accept_alert do
      click_link "解決にする"
    end
    assert_text "正解の解答を選択しました。"
    assert_no_text "解決にする"
  end

  test "delete best answer" do
    visit "/questions/#{questions(:question_2).id}"
    accept_alert do
      click_link "解決にする"
    end
    accept_alert do
      click_link "ベストアンサーを取り消す"
    end
    assert_text "ベストアンサーを取り消しました。"
    assert_text "解決にする"
  end
end
