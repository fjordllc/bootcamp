# frozen_string_literal: true

require "application_system_test_case"

class AnswersTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "answer form in questions/:id has comment tab and preview tab" do
    visit "/questions/#{questions(:question_2).id}"
    comment_form_tabs = all(".thread-comment-form__tab")
    assert_equal "コメント", comment_form_tabs[0].text
    assert_equal "プレビュー", comment_form_tabs[1].text
  end

  test "answer form in questions/:question_id/answers/:id/edit has comment tab and preview tab" do
    answer = answers(:answer_3)
    visit "/questions/#{answer.question_id}/answers/#{answer.id}/edit"
    comment_form_tabs = all(".thread-comment-form__tab")
    assert_equal "コメント", comment_form_tabs[0].text
    assert_equal "プレビュー", comment_form_tabs[1].text
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
end
