# frozen_string_literal: true

require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "previous" do
    assert_equal reports(:report_1), reports(:report_2).previous
  end

  test "next" do
    assert_equal reports(:report_2), reports(:report_1).next
  end
end
