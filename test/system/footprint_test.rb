# frozen_string_literal: true

require "application_system_test_case"

class FootprintTest < ApplicationSystemTestCase
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

  test "should be create footprint in /announcements/:id" do
    login_user "tanaka", "testtest"
    announce = users(:komagata).announcements.first
    visit announcement_path(announce)
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end

  test "should not footpoint with my own announcement" do
    login_user "komagata", "testtest"
    announce = users(:komagata).announcements.first
    visit announcement_path(announce)
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
