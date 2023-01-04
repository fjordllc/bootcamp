# frozen_string_literal: true

require 'test_helper'

class SurveysHelperTest < ActionView::TestCase
  test 'question_options_within_survey_question' do
    assert_equal 'フィヨルドブートキャンプの学習を通して、どんなことを学びましたか？', question_options_within_survey_question[0][0]
    assert_equal 'フィヨルドブートキャンプに対してご意見・ご要望がございましたら、ご自由にお書きください。', question_options_within_survey_question[5][0]
  end
end
