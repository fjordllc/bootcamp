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

  test "count_report" do
    report1 = reports(:report_1)
    report2 = reports(:report_2)
    assert_equal report1.count_report, 1
    assert_equal report2.count_report, 2
  end
end
