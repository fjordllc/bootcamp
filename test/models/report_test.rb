require "test_helper"

class ReportTest < ActiveSupport::TestCase
  def setup 
    reports(:report_2).id = 3
    reports(:report_3).id = 2
  end
  
  test "Should get previous report" do
    report = reports(:report_3)
    assert report.previous, reports(:report_1)
  end
  
  test "Should get next report" do
    report = reports(:report_3)
    assert report.next, reports(:report_2)
  end
end
