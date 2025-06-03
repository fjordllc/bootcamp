# frozen_string_literal: true

require 'application_system_test_case'

class ReportValidationTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'cannot post a new report with future date' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: '学習日が未来日では日報を作成できない')
      fill_in('report[description]', with: 'エラーになる')
      fill_in('report[reported_on]', with: Date.current.next_day)
    end
    click_button '提出'
    assert_text '学習日は2013年01月01日から今日以前の間の日付にしてください'
  end

  test 'cannot post a new report with min date' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: '学習日が2013年1月1日より前では日報を作成できない')
      fill_in('report[description]', with: 'エラーになる')
      fill_in('report[reported_on]', with: Date.new(2012, 12, 31))
    end
    click_button '提出'
    html_validataion_message = page.find('#report_reported_on').native.attribute('validationMessage')
    assert_not_nil html_validataion_message
    assert_not_empty html_validataion_message
  end
end
