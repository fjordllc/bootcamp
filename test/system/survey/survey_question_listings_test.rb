# frozen_string_literal: true

require 'application_system_test_case'

class Survey::SurveyQuestionListingsTest < ApplicationSystemTestCase
  test 'sorting questions of a survey_question_listings' do
    visit_with_auth "/surveys/#{surveys(:survey1).id}/", 'komagata'
    assert_equal all('label.a-form-label.is-lg')[0].text, survey_questions(:survey_question1).title
    assert_equal all('label.a-form-label.is-lg')[1].text, survey_questions(:survey_question2).title

    visit_with_auth "/surveys/#{surveys(:survey1).id}/survey_question_listings", 'komagata'
    source = all('.js-grab')[0] # surveyQuestion1
    target = all('.js-grab')[1] # surveyQuestion2
    source.drag_to(target)
    assert_equal all('.js-grab')[0].text, survey_questions(:survey_question2).title
    assert_equal all('.js-grab')[1].text, survey_questions(:survey_question1).title

    visit_with_auth "/surveys/#{surveys(:survey1).id}/", 'komagata'
    assert_equal all('label.a-form-label.is-lg')[0].text, survey_questions(:survey_question2).title
    assert_equal all('label.a-form-label.is-lg')[1].text, survey_questions(:survey_question1).title
  end
end
