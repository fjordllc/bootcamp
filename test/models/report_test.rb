require "test_helper"

class ReportTest < ActiveSupport::TestCase
  #前の日報の取得
  test "Should get previous report" do
    report = reports(:report_3)
    assert report.previous, reports(:report_1)
  end
  
  #次の日報の取得
  test "Should get next report" do
    report = reports(:report_3)
    assert report.next, reports(:report_2)
  end
end
