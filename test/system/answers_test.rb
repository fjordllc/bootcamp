# frozen_string_literal: true

require "application_system_test_case"

class AnswersTest < ApplicationSystemTestCase
  test "admin can resolve user's question" do
    login_user "komagata", "testtest"
    visit "/questions/#{questions(:question_2).id}"
    assert_text "解決にする"
    accept_alert do
      click_link "解決にする"
    end
    assert_text "正解の解答を選択しました。"
    assert_no_text "解決にする"
  end

  test "answers order by created at" do
    login_user "komagata", "testtest"

    click_link "Q&A"
    assert_text "テストの質問2"

    click_link "テストの質問2"
    2.times { |n| post_comment "テストの回答#{n}" }
    answers_before_update = page.all(".thread-comments__description").map(&:text)
    assert_equal "テストの回答0", answers_before_update[0]
    assert_equal "テストの回答1", answers_before_update[1]

    first(".thread-comment__actions-item-link").click
    post_comment "【更新】テストの回答0"
    answers_after_update = page.all(".thread-comments__description").map(&:text)
    assert_equal "【更新】テストの回答0", answers_after_update[0]
    assert_equal "テストの回答1", answers_after_update[1]
  end

  def post_comment(content)
    fill_in "answer_description", with: content
    click_button "コメントを投稿"
  end
end
