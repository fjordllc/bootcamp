# frozen_string_literal: true

require 'application_system_test_case'

class Question::AnswersTest < ApplicationSystemTestCase
  test 'permission decision best answer' do
    visit_with_auth new_question_path, 'kimura'
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'テストの質問タイトル'
      fill_in 'question[description]', with: 'テストの質問です。'
      click_button '登録する'
    end
    fill_in 'answer[description]', with: 'アンサーテスト'
    click_button 'コメントする'
    within '.a-card.is-answer.answer-display' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path(target: 'not_solved'), 'komagata'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer.answer-display' do
      assert_text '内容修正'
      assert_text 'ベストアンサーにする'
      assert_text '削除する'
    end

    visit_with_auth questions_path(target: 'not_solved'), 'hatsuno'
    click_on 'テストの質問タイトル'
    within '.a-card.is-answer.answer-display' do
      assert_no_text '内容修正'
      assert_no_text 'ベストアンサーにする'
      assert_no_text '削除する'
    end
  end
end
