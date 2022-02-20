# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#previous' do
    assert_equal reports(:report1), reports(:report2).previous
    assert_equal reports(:report22), reports(:report26).previous
    assert_equal reports(:report27), reports(:report22).previous
  end

  test '#next' do
    assert_equal reports(:report2), reports(:report1).next
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
    assert_equal report1.serial_number, 1
    assert_equal report2.serial_number, 2
  end

  test '#total_learning_time' do
    assert_equal 420, reports(:report1).total_learning_time
    assert_equal 0, reports(:report3).total_learning_time
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

  test '#latest?' do
    assert_not reports(:report31).latest?
    assert reports(:report32).latest?
  end

  test '#interval' do
    assert_equal 10, reports(:report32).interval
  end
end
