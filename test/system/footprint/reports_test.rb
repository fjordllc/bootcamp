# frozen_string_literal: true

require "application_system_test_case"

class Footprint::ReportsTest < ApplicationSystemTestCase
  test "should be create footprint in /reports/:id" do
    login_user "tanaka", "testtest"
    report = users(:komagata).reports.first
    visit report_path(report)
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end

  test "should not footpoint with my own report" do
    login_user "tanaka", "testtest"
    report = users(:tanaka).reports.first
    visit report_path(report)
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
