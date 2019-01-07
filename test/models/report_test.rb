# frozen_string_literal: true

require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "previous" do
    assert reports(:report_2).previous, reports(:report_1)
  end

  test "next" do
    assert reports(:report_1).next, reports(:report_2)
  end

  test "unchecked_and_not_wip" do
    assert_equal 3, Report.unchecked_and_not_wip.count
  end
end
