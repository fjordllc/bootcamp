# frozen_string_literal: true

require 'application_system_test_case'

class ReportTemplateTest < ApplicationSystemTestCase
  test 'register template' do
    visit_with_auth '/reports/new', 'yamada'
    click_button 'テンプレート登録'
    fill_in('report_template[description]', with: 'create test')
    click_button '登録'
    visit_with_auth '/reports/new', 'yamada'
    click_button 'テンプレート変更'
    assert_text 'create test'
  end

  test 'update template' do
    visit_with_auth '/reports/new', 'hajime'
    click_button 'テンプレート変更'
    fill_in('report_template[description]', with: 'update test')
    click_button '変更'
    visit_with_auth '/reports/new', 'hajime'
    click_button 'テンプレート変更'
    assert_text 'update test'
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
end
