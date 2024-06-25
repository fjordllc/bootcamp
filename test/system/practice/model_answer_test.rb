# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ModelAnswerTest < ApplicationSystemTestCase
  test 'student passed practice can show model answer' do
    practice = practices(:practice1)

    visit_with_auth practice_path(practice), 'kimura'
    assert find_button('修了')[:disabled]
    visit practice_model_answer_path(practice)
    assert_text '「OS X Mountain Lionをクリーンインストールする」の模範解答'
    assert_text 'description...'
  end

  test 'student not passed practice can not show model answer' do
    practice = practices(:practice1)

    visit_with_auth practice_path(practice), 'kimura'
    click_on '未着手'
    assert find_button('未着手')[:disabled]
    visit practice_model_answer_path(practice)
    assert_text 'プラクティスを修了するまで模範解答は見れません。'
  end
end
