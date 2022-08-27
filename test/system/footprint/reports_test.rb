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

  test 'show link if there are more than ten footprints' do
    report = users(:komagata).reports.first
    visit_with_auth report_path(report), 'kimura'
    visit_with_auth report_path(report), 'machida'
    visit_with_auth report_path(report), 'osnashi'
    visit_with_auth report_path(report), 'marumarushain2'
    visit_with_auth report_path(report), 'kananasi'
    visit_with_auth report_path(report), 'nippounashi'
    visit_with_auth report_path(report), 'hatsuno'
    visit_with_auth report_path(report), 'jobseeker'
    visit_with_auth report_path(report), 'advijirou'
    visit_with_auth report_path(report), 'hajime'
    visit_with_auth report_path(report), 'muryou'
    assert page.has_css?('.page-content-prev-next__item-link')
  end

  test 'has no link if there are less than ten footprints' do
    report = users(:komagata).reports.first
    visit_with_auth report_path(report), 'kimura'
    visit_with_auth report_path(report), 'machida'
    visit_with_auth report_path(report), 'osnashi'
    visit_with_auth report_path(report), 'marumarushain2'
    visit_with_auth report_path(report), 'kananasi'
    visit_with_auth report_path(report), 'nippounashi'
    visit_with_auth report_path(report), 'hatsuno'
    visit_with_auth report_path(report), 'jobseeker'
    visit_with_auth report_path(report), 'advijirou'
    visit_with_auth report_path(report), 'hajime'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end
end
