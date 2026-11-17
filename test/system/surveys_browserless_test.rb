# frozen_string_literal: true

require 'browserless_system_test_case'

class SurveysBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @survey = surveys(:survey1)
    @user = users(:komagata)
  end

  test 'user can view survey' do
    visit_with_auth survey_path(@survey), 'komagata'
    assert_selector 'h1', text: @survey.title
    assert_text @survey.description
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
end
