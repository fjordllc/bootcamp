# frozen_string_literal: true

require 'application_system_test_case'

class SurveysTest < ApplicationSystemTestCase
  setup do
    @survey = surveys(:survey1)
    @user = users(:komagata)
  end

  test 'user can view survey' do
    visit_with_auth survey_path(@survey), 'komagata'
    assert_selector 'h1', text: @survey.title
    assert_text @survey.description
  end

  test 'user can answer all question types at once' do
    visit_with_auth survey_path(@survey), 'komagata'

    # テキストエリア
    text_area = find('textarea')
    text_area.fill_in with: 'テキストエリアの回答です。'

    # ラジオボタン
    radio_buttons = find('.survey-questions-item__radios').all('.radios__item')
    radio_buttons.first.click

    # チェックボックス
    check_boxes = find('.survey-questions-item__checkboxes').all('.checkboxes__item')
    check_boxes.first.click

    # テキストフィールド
    text_field = find('input[type="text"]')
    text_field.fill_in with: 'テキストフィールドの回答です。'

    # リニアスケール
    linear_scale_points = find('.linear-scale__points-items').all('.linear-scale__points-item')
    linear_scale_points.first.click

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end

  test 'user cannot answer survey twice' do
    # 1回目の回答
    visit_with_auth survey_path(@survey), 'komagata'
    text_area = find('textarea')
    text_area.fill_in with: 'テキストエリアの回答です。'
    click_button '回答する'
    assert_text 'アンケートに回答しました。'

    # 2回目の回答を試みる
    visit survey_path(@survey)
    assert_text 'このアンケートには既に回答済みです。'
  end

  test 'required reason field appears when specific radio button is selected' do
    visit_with_auth survey_path(@survey), 'komagata'

    # 理由入力が必要なラジオボタンを選択
    radio_buttons = find('.survey-questions-item__radios').all('.radios__item')
    radio_buttons.last.click

    # 理由入力フィールドが表示されることを確認
    assert_selector '.survey-questions-item__reason'

    # 理由を入力
    reason_field = find('.survey-questions-item__reason textarea')
    reason_field.fill_in with: '理由を入力します。'

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end

  test 'required reason field appears when specific checkbox is selected' do
    visit_with_auth survey_path(@survey), 'komagata'

    # 理由入力が必要なチェックボックスを選択
    check_boxes = find('.survey-questions-item__checkboxes').all('.checkboxes__item')
    check_boxes.last.click

    # 理由入力フィールドが表示されることを確認
    assert_selector '.survey-questions-item__reason'

    # 理由を入力
    reason_field = find('.survey-questions-item__reason textarea')
    reason_field.fill_in with: '理由を入力します。'

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end
end
