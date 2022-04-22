# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::ReportsTest < ApplicationSystemTestCase
  test 'should be create footprint in /reports/:id' do
    report = users(:komagata).reports.first
    visit_with_auth report_path(report), 'sotugyou'
    assert_text '見たよ'
    assert page.has_css?('.a-user-icon.is-sotugyou')
  end

  test 'should not footpoint with my own report' do
    report = users(:sotugyou).reports.first
    visit_with_auth report_path(report), 'sotugyou'
    assert_no_text '見たよ'
    assert_not page.has_css?('.a-user-icon.is-sotugyou')
  end
end
