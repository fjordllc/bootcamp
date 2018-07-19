require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "Should get previous report" do
    report = reports(:report_3)
    assert report.previous, reports(:report_1)
  end
  
  test "Should get next report" do
    report = reports(:report_3)
    assert report.next, reports(:report_2)
  end
end
