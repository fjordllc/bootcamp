# frozen_string_literal: true

require 'application_system_test_case'

class Practice::SubmissionAnswerTest < ApplicationSystemTestCase
  setup do
    @practice = practices(:practice1)
  end

  test 'student passed practice and product can show submission answer' do
    user = users(:kimura)
    visit_with_auth practice_path(@practice), user.login_name
    assert @practice.product(user).checked?
    assert find_button('修了', disabled: true)
    click_on '模範解答'
    assert_text '「OS X Mountain Lionをクリーンインストールする」の模範解答'
    assert_text 'description...'
  end

  test 'student not passed practice and product can not show submission answer' do
    user = users(:kensyu)
    visit_with_auth practice_path(@practice), user.login_name
    assert_not @practice.product(user).checked?
    assert find_button('未着手', disabled: true)
    visit practice_submission_answer_path(@practice)
    assert_text 'プラクティスを修了するまで模範解答は見れません。'
  end

  test 'student cannnot access new and edit page' do
    visit_with_auth edit_mentor_practice_submission_answer_path(@practice), 'kimura'
    assert_text '管理者・メンターとしてログインしてください'

    practice = practices(:practice2)
    practice.submission_answer = nil
    visit new_mentor_practice_submission_answer_path(practice)
    assert_text '管理者・メンターとしてログインしてください'
  end
end
