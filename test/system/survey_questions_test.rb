# frozen_string_literal: true

require 'application_system_test_case'

class SurveyQuestionsTest < ApplicationSystemTestCase
  test 'create text area question' do
    visit_with_auth '/survey_questions/new', 'komagata'
    fill_in 'survey_question[question_title]', with: 'フィヨルドブートキャンプに入会した理由は何ですか？'
    choose '段落', allow_label_click: true
    click_button '保存'
    assert_text 'フィヨルドブートキャンプに入会した理由は何ですか？'
  end

  test 'create input question' do
    visit_with_auth '/survey_questions/new', 'komagata'
    fill_in 'survey_question[question_title]', with: '一番辛かったプラクティスは何ですか？'
    choose '記述式', allow_label_click: true
    click_button '保存'
    assert_text '一番辛かったプラクティスは何ですか？'
  end

  test 'create radio button question' do
    visit_with_auth '/survey_questions/new', 'komagata'
    fill_in 'survey_question[question_title]', with: 'フィヨルドブートキャンプの内容に対して、どのくらい満足していますか？'
    choose 'ラジオボタン', allow_label_click: true
    click_link '追加'
    find("input[name*='[choices]']").set('満足しています')
    fill_in 'survey_question[radio_button_attributes][title_of_reason_for_choice]', with: '選択した理由を教えてください。'
    click_button '保存'
    assert_text 'フィヨルドブートキャンプの内容に対して、どのくらい満足していますか？'
  end

  test 'create check box question' do
    visit_with_auth '/survey_questions/new', 'komagata'
    fill_in 'survey_question[question_title]', with: '就職についてどんな不安を抱えていますか？'
    choose 'チェックボックス', allow_label_click: true
    click_link '追加'
    find("input[name*='[choices]']").set('エンジニアとしてやっていけるか不安')
    fill_in 'survey_question[check_box_attributes][title_of_reason_for_choice]', with: 'その他の内容を教えてください。'
    click_button '保存'
    assert_text '就職についてどんな不安を抱えていますか？'
  end

  test 'create linear scale question' do
    visit_with_auth '/survey_questions/new', 'komagata'
    fill_in 'survey_question[question_title]', with: 'フィヨルドブートキャンプを親しい友人や家族にお薦めする可能性はどれくらいありますか？'
    choose '均等目盛', allow_label_click: true
    fill_in 'survey_question[linear_scale_attributes][start_of_scale]', with: 'お薦めしない'
    fill_in 'survey_question[linear_scale_attributes][end_of_scale]', with: 'お薦めする'
    fill_in 'survey_question[linear_scale_attributes][title_of_reason_for_choice]', with: 'そのように回答された理由を詳しく教えてください。'
    click_button '保存'
    assert_text 'フィヨルドブートキャンプを親しい友人や家族にお薦めする可能性はどれくらいありますか？'
  end
end
