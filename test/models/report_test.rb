# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#previous' do
    assert_equal reports(:report_1), reports(:report_2).previous
  end

  test '#next' do
    assert_equal reports(:report_2), reports(:report_1).next
  end

  test '#anchor' do
    report = reports(:report_1)
    assert_equal "report_#{report.id}", report.anchor
  end

  test '#path' do
    report = reports(:report_1)
    assert_equal "/reports/#{report.id}", report.path
  end

  test '#serial_number' do
    report1 = reports(:report_1)
    report2 = reports(:report_2)
    assert_equal report1.serial_number, 1
    assert_equal report2.serial_number, 2
  end

  test 'adviser watches trainee report when trainee create report' do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    report = Report.new(
      title: 'test',
      description: 'test text',
      reported_on: Date.parse('2020-01-01'),
      user: trainee
    )
    report.learning_times.build(
      started_at: Time.zone.parse('2020-01-01 10:00:00'),
      finished_at: Time.zone.parse('2020-01-01 11:00:00')
    )
    report.save!
    assert_not_nil Watch.find_by(user: adviser, watchable: report)
  end
end
