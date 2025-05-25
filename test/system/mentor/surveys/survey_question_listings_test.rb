# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::Surveys::SurveyQuestionListingsTest < ApplicationSystemTestCase
  test 'sorting survey_questions of a survey ' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}/", 'komagata'
    assert_equal survey_questions(:survey_question1).title, all('label.a-form-label.is-lg')[0].text
    assert_equal survey_questions(:survey_question2).title, all('label.a-form-label.is-lg')[1].text

    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}/survey_questions", 'komagata'
    source = all('.js-grab')[0]
    target = all('.js-grab')[2]
    source.drag_to(target)
    assert_equal survey_questions(:survey_question2).title, all('td.admin-table__item-value')[0].text
    assert_equal survey_questions(:survey_question1).title, all('td.admin-table__item-value')[2].text

    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}/", 'komagata'
    assert_equal survey_questions(:survey_question2).title, all('label.a-form-label.is-lg')[0].text
    assert_equal survey_questions(:survey_question1).title, all('label.a-form-label.is-lg')[1].text
  end

  test 'sorting survey_questions of a survey not affecting the survey_questions order of another survey' do
    visit_with_auth "/mentor/surveys/#{surveys(:survey2).id}/", 'komagata'
    assert_equal survey_questions(:survey_question1).title, all('label.a-form-label.is-lg')[0].text
    assert_equal survey_questions(:survey_question2).title, all('label.a-form-label.is-lg')[1].text

    visit_with_auth "/mentor/surveys/#{surveys(:survey1).id}/survey_questions", 'komagata'
    assert_equal survey_questions(:survey_question1).title, all('td.admin-table__item-value')[0].text
    assert_equal survey_questions(:survey_question2).title, all('td.admin-table__item-value')[2].text
    source = all('.js-grab')[0]
    target = all('.js-grab')[2]
    source.drag_to(target)
    assert_equal survey_questions(:survey_question2).title, all('td.admin-table__item-value')[0].text
    assert_equal survey_questions(:survey_question1).title, all('td.admin-table__item-value')[2].text

    # survey1の質問並び替え後もsurvey2の質問の並び順には変化がないことを確認
    visit_with_auth "/mentor/surveys/#{surveys(:survey2).id}/", 'komagata'
    assert_equal survey_questions(:survey_question1).title, all('label.a-form-label.is-lg')[0].text
    assert_equal survey_questions(:survey_question2).title, all('label.a-form-label.is-lg')[1].text
  end
end
