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

  test '#latest_of_user?' do
    assert_not reports(:report31).latest_of_user?
    assert reports(:report32).latest_of_user?
  end

  test '#interval' do
    assert_equal 10, reports(:report32).interval
  end

  test '#reported_on_uniqueness_check' do
    user = users(:muryou)
    report1 = Report.new
    report1.user = user
    report1.reported_on = '2024-08-05'
    report1.title = 'test1'
    report1.description = 'test1'
    report1.emotion = 'happy'
    report1.save_with_uniqueness_check

    report2 = Report.new
    report2.user = user
    report2.reported_on = '2024-08-05'
    report2.title = 'test2'
    report2.description = 'test2'
    report2.emotion = 'happy'
    report2.save_with_uniqueness_check

    assert_includes report2.errors.full_messages, '学習日はすでに存在します'
  end
end
