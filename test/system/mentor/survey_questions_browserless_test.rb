# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::SurveyQuestionsBrowserlessTest < BrowserlessSystemTestCase
  test 'display a list of questions' do
    survey_question = survey_questions(:survey_question1)

    visit_with_auth '/mentor/survey_questions', 'komagata'
    assert_text '段落'
    assert_text 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？'
    assert_text "作成: #{I18n.l(survey_question.created_at, format: :long)}"
    assert_text "更新: #{I18n.l(survey_question.updated_at, format: :long)}"
  end
end
