# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ModelAnswerTest < ApplicationSystemTestCase
  setup do
    @practice = practices(:practice1)
  end

  test 'student passed practice can show model answer' do
    visit_with_auth practice_path(@practice), 'kimura'
    assert find_button('修了')[:disabled]
    visit practice_model_answer_path(@practice)
    assert_text '「OS X Mountain Lionをクリーンインストールする」の模範解答'
    assert_text 'description...'
  end

  test 'student not passed practice can not show model answer' do
    visit_with_auth practice_path(@practice), 'kimura'
    click_on '未着手'
    assert find_button('未着手')[:disabled]
    visit practice_model_answer_path(@practice)
    assert_text 'プラクティスを修了するまで模範解答は見れません。'
  end

  test 'mentor can create model answer' do
    practice = practices(:practice2)

    visit_with_auth new_mentor_practice_model_answer_path(practice), 'komagata'
    fill_in '内容', with: '模範解答内容です。'
    click_on '登録する'
    assert_current_path practice_model_answer_path(practice)
    assert_text '「Terminalの基礎を覚える」の模範解答'
    assert_text '模範解答内容です。'
  end

  test 'mentor can update model answer' do
    visit_with_auth edit_mentor_practice_model_answer_path(@practice), 'komagata'
    fill_in '内容', with: '新しい模範解答内容です。'
    click_on '更新する'
    assert_current_path practice_model_answer_path(@practice)
    assert_text '「OS X Mountain Lionをクリーンインストールする」の模範解答'
    assert_text '新しい模範解答内容です。'
  end
end
