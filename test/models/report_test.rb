# frozen_string_literal: true

require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "previous" do
    assert_equal reports(:report_1), reports(:report_2).previous
  end

  test "next" do
    assert_equal reports(:report_2), reports(:report_1).next
  end

  test "adviser watches trainee report when trainee create report" do
    trainee = users(:kensyu)
    adviser = users(:senpai)
    report = Report.new(title: "test", user: trainee)
    report.save(validate: false)
    assert_not_nil Watch.find_by(user: adviser, watchable: report)
  end

  test "serial_number" do
    report1 = reports(:report_1)
    report2 = reports(:report_2)
    assert_equal report1.serial_number, 1
    assert_equal report2.serial_number, 2
  end
end
