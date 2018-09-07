require "application_system_test_case"

class CorrectAnswerTest < ApplicationSystemTestCase

  test "admin can resolve user's question" do
    login_user "komagata", "testtest"
    click_link "Q&A"
    click_link "injectとreduce"
    assert_text "解決にする"
    accept_alert do
      click_link '解決にする'
    end
    assert_text "正解の解答を選択しました。"
    assert_no_text "解決にする"
  end
end
