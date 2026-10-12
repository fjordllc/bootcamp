# frozen_string_literal: true

require 'application_system_test_case'

class ReportPresetsTest < ApplicationSystemTestCase
  test 'register template' do
    visit_with_auth '/reports/new', 'mentormentaro'
    click_button 'テンプレート登録'
    fill_in 'report_preset[description]', with: 'create test'
    click_button '登録'
    assert_text 'テンプレートを登録しました！'
    assert_no_button 'テンプレート登録'
    assert_button 'テンプレート変更'
    assert_selector 'a', text: 'テンプレートを反映する'
    fill_in 'report[description]', with: ''
    find('a', text: 'テンプレートを反映する').click
    assert_field 'report[description]', with: 'create test'
  end

  test 'update template' do
    visit_with_auth '/reports/new', 'hajime'
    click_button 'テンプレート変更'
    fill_in 'report_preset[description]', with: 'update test'
    click_button '変更'
    assert_text 'テンプレートを変更しました！'
    fill_in 'report[description]', with: ''
    find('a', text: 'テンプレートを反映する').click
    assert_field 'report[description]', with: 'update test'
    click_button 'テンプレート変更'
    assert_field 'report_preset[description]', with: 'update test'
  end

  test 'new report is replaced with template' do
    visit_with_auth '/reports/new', 'hajime'
    assert_text 'template test hajime'
  end

  test 'replace button works' do
    visit_with_auth '/reports/new', 'hajime'
    fill_in('report[description]', with: '')
    find('a', text: 'テンプレートを反映する').click
    assert_text 'template test hajime'
  end

  test 'update button is disabled with no difference between edited & registered contents' do
    visit_with_auth '/reports/new', 'hajime'
    click_button 'テンプレート変更'
    assert has_button?('変更', disabled: true)
  end

  test 'registered template is set when user abort editing and then restart editing again' do
    visit_with_auth '/reports/new', 'hajime'
    click_button 'テンプレート変更'
    fill_in('report_preset[description]', with: 'update test')
    find('div.card-main-actions__muted-action', text: 'キャンセル').click
    click_button 'テンプレート変更'
    textarea = find('#js-preset-content')
    assert_equal 'template test hajime', textarea.value
  end
end
