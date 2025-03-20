# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::SurveyQuestionsTest < ApplicationSystemTestCase
  test 'create text area question' do
    visit_with_auth '/mentor/survey_questions/new', 'komagata'
    fill_in 'survey_question[title]', with: 'フィヨルドブートキャンプに入会した理由は何ですか？'
    choose '段落', allow_label_click: true
    click_button '保存'
    assert_text '段落'
    assert_text 'フィヨルドブートキャンプに入会した理由は何ですか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'create input question' do
    visit_with_auth '/mentor/survey_questions/new', 'komagata'
    fill_in 'survey_question[title]', with: '一番辛かったプラクティスは何ですか？'
    choose '記述式', allow_label_click: true
    click_button '保存'
    assert_text '記述式'
    assert_text '一番辛かったプラクティスは何ですか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'create radio button question' do
    visit_with_auth '/mentor/survey_questions/new', 'komagata'
    fill_in 'survey_question[title]', with: 'フィヨルドブートキャンプの内容に対して、どのくらい満足していますか？'
    choose 'ラジオボタン', allow_label_click: true
    click_link '追加'
    find("input[name*='[choices]']").set('満足しています')
    fill_in 'survey_question[radio_button_attributes][title_of_reason]', with: '選択した理由を教えてください。'
    click_button '保存'
    assert_text 'ラジオボタン'
    assert_text 'フィヨルドブートキャンプの内容に対して、どのくらい満足していますか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'create check box question' do
    visit_with_auth '/mentor/survey_questions/new', 'komagata'
    fill_in 'survey_question[title]', with: '就職についてどんな不安を抱えていますか？'
    choose 'チェックボックス', allow_label_click: true
    click_link '追加'
    find("input[name*='[choices]']").set('プログラマーとしてやっていけるか不安')
    fill_in 'survey_question[check_box_attributes][title_of_reason]', with: 'その他の内容を教えてください。'
    click_button '保存'
    assert_text 'チェックボックス'
    assert_text '就職についてどんな不安を抱えていますか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'create linear scale question' do
    visit_with_auth '/mentor/survey_questions/new', 'komagata'
    fill_in 'survey_question[title]', with: 'フィヨルドブートキャンプを親しい友人や家族にお薦めする可能性はどれくらいありますか？'
    choose '均等目盛', allow_label_click: true
    fill_in 'survey_question[linear_scale_attributes][first]', with: 'お薦めしない'
    fill_in 'survey_question[linear_scale_attributes][last]', with: 'お薦めする'
    fill_in 'survey_question[linear_scale_attributes][title_of_reason]', with: 'そのように回答された理由を詳しく教えてください。'
    click_button '保存'
    assert_text '均等目盛'
    assert_text 'フィヨルドブートキャンプを親しい友人や家族にお薦めする可能性はどれくらいありますか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'display a list of questions' do
    visit_with_auth '/mentor/survey_questions', 'komagata'
    assert_text '段落'
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end

  test 'edit question' do
    visit_with_auth '/mentor/survey_questions', 'komagata'
    assert_text '段落'
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    first('#edit_icon').click
    fill_in 'survey_question[title]', with: '一番辛かったプラクティスは何ですか？'
    choose '記述式', allow_label_click: true
    click_button '保存'
    assert_text '記述式'
    assert_text '一番辛かったプラクティスは何ですか？'
    assert_text "作成: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
    assert_text "更新: #{Time.current.strftime("%Y年%m月%d日(#{%w[日 月 火 水 木 金 土][Time.current.wday]})")}"
  end
end
