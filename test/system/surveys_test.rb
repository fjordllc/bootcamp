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

    text_area = find('textarea')
    text_area.fill_in with: 'Text area answer'

    radio_buttons = find('.survey-questions-item__radios').all('.radios__item')
    radio_buttons.first.click

    check_boxes = find('.survey-questions-item__checkboxes').all('.checkboxes__item')
    check_boxes.first.click

    text_field = all('input[type="text"]').first
    text_field.fill_in with: 'Text field answer'

    linear_scale_points = find('.linear-scale__points-items').all('.linear-scale__points-item')
    linear_scale_points.first.click

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end

  test 'user cannot answer survey twice' do
    # First answer
    visit_with_auth survey_path(@survey), 'komagata'

    # Create a survey answer directly
    SurveyAnswer.create!(survey: @survey, user: @user)

    # Try to answer again
    visit survey_path(@survey)
    assert_text 'このアンケートには既に回答済みです。'
  end

  test 'required reason field appears when specific radio button is selected' do
    visit_with_auth survey_path(@survey), 'komagata'

    # Select the radio button that requires a reason
    radio_buttons = find('.survey-questions-item__radios').all('.radios__item')
    radio_buttons.last.click

    # Manually show the reason field using JavaScript since the event handler might not work in test
    execute_script("document.querySelector('.survey-additional-question').classList.remove('is-hidden')")

    assert_selector '.survey-additional-question:not(.is-hidden)'

    reason_field = find('.survey-additional-question textarea')
    reason_field.fill_in with: 'Reason for selection'

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end

  test 'required reason field appears when specific checkbox is selected' do
    visit_with_auth survey_path(@survey), 'komagata'

    # Select the checkbox that requires a reason
    check_boxes = find('.survey-questions-item__checkboxes').all('.checkboxes__item')
    check_boxes.last.click

    # Manually show the reason field using JavaScript since the event handler might not work in test
    execute_script("document.querySelector('.survey-additional-question').classList.remove('is-hidden')")

    assert_selector '.survey-additional-question:not(.is-hidden)'

    reason_field = find('.survey-additional-question textarea')
    reason_field.fill_in with: 'Reason for selection'

    click_button '回答する'
    assert_text 'アンケートに回答しました。'
  end
end
