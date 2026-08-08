# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#previous' do
    assert_equal reports(:report1), ReportOrder.new(reports(:report2)).previous
    assert_equal reports(:report22), ReportOrder.new(reports(:report26)).previous
    assert_equal reports(:report27), ReportOrder.new(reports(:report22)).previous
  end

  test '#next' do
    assert_equal reports(:report2), ReportOrder.new(reports(:report1)).next
  end

  test '#anchor' do
    report = reports(:report1)
    assert_equal "report_#{report.id}", report.anchor
  end

  test '#path' do
    report = reports(:report1)
    assert_equal "/reports/#{report.id}", report.path
  end

  test '#serial_number' do
    report1 = reports(:report1)
    report2 = reports(:report2)
    assert_equal ReportOrder.new(report1).serial_number, 1
    assert_equal ReportOrder.new(report2).serial_number, 2
  end

  test '#total_learning_time' do
    assert_equal 420, reports(:report1).total_learning_time
    assert_equal 0, reports(:report3).total_learning_time
  end

  test '#latest_of_user?' do
    assert_not ReportOrder.new(reports(:report31)).latest_of_user?
    assert ReportOrder.new(reports(:report32)).latest_of_user?
  end

  test '#interval' do
    assert_equal 10, ReportOrder.new(reports(:report32)).interval
  end

  test 'save_uniquely does not save duplicate report and adds validation errors' do
    Report.create!(
      user: users(:komagata),
      reported_on: Time.zone.today,
      title: 'report1',
      description: 'report1本文'
    )

    duplicate_report = Report.new(
      user: users(:komagata),
      reported_on: Time.zone.today,
      title: 'report2',
      description: 'report2本文'
    )
    assert_not duplicate_report.save_uniquely
    assert_includes duplicate_report.errors.full_messages, '学習日はすでに存在します'
  end

  test 'unchecked scope returns reports without checks' do
    unchecked_report = Report.create!(
      user: users(:kimura),
      reported_on: Time.zone.today,
      title: 'テスト未チェックレポート',
      description: '本文'
    )

    assert_empty unchecked_report.checks
    assert_includes Report.unchecked, unchecked_report
  end

  test '.for_practice_including_source returns practice and source reports' do
    practice = practices(:practice66)
    practice_report = reports(:report77)
    source_report = reports(:report76)
    practice_and_source_report = reports(:report78)
    other_report = reports(:report79)
    unrelated_report = reports(:report80)
    result = Report.for_practice_including_source(practice)

    assert_includes result, practice_report
    assert_includes result, source_report
    assert_includes result, practice_and_source_report
    assert_not_includes result, other_report
    assert_not_includes result, unrelated_report
  end
end
