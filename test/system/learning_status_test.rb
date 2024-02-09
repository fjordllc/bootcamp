# frozen_string_literal: true

require 'application_system_test_case'

class LearningStatusTest < ApplicationSystemTestCase
  test 'learning status changes to submitted after the mentor cancels the confirmation' do
    visit_with_auth "/products/#{products(:product8).id}", 'machida'
    click_button '担当する'
    click_button '提出物を確認'
    click_button '提出物の確認を取り消す'
    visit_with_auth course_practices_path(courses(:course1).id), 'kimura'
    assert_selector 'a', text: '提出'
  end

  test 'learning status changes to submitted after the mentor cancels the confirmation with comment' do
    visit_with_auth "/products/#{products(:product8).id}", 'machida'
    click_button '担当する'
    fill_in('new_comment[description]', with: 'LGTMです。')
    accept_alert do
      click_button '確認OKにする'
    end
    click_button '提出物の確認を取り消す'
    visit_with_auth course_practices_path(courses(:course1).id), 'kimura'
    assert_selector 'a', text: '提出'
  end
end
