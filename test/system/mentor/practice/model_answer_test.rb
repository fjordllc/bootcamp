# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::Practices::ModelAnswerTest < ApplicationSystemTestCase
  test 'mentor can create model answer' do
    practice = practices(:practice2)
    practice.model_answer = nil

    visit_with_auth new_mentor_practice_model_answer_path(practice), 'komagata'
    fill_in '内容', with: '模範解答内容です。'
    click_on '登録する'
    assert_current_path practice_model_answer_path(practice)
    assert_text '「Terminalの基礎を覚える」の模範解答'
    assert_text '模範解答内容です。'
  end

  test 'mentor can update model answer' do
    practice = practices(:practice1)

    visit_with_auth edit_mentor_practice_model_answer_path(practice), 'komagata'
    fill_in '内容', with: '新しい模範解答内容です。'
    click_on '更新する'
    assert_current_path practice_model_answer_path(practice)
    assert_text '「OS X Mountain Lionをクリーンインストールする」の模範解答'
    assert_text '新しい模範解答内容です。'
  end
end
