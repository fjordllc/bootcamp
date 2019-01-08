# frozen_string_literal: true

require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "previous" do
    assert reports(:report_2).previous, reports(:report_1)
  end

  test "next" do
    assert reports(:report_1).next, reports(:report_2)
  end
end
