# frozen_string_literal: true

require "application_system_test_case"

class FootprintTest < ApplicationSystemTestCase
  test "should be create footprint" do
    login_user "tanaka", "testtest"
    visit "/reports/#{reports(:report_2).id}"
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end

  test "should not footpoint with my report" do
    login_user "tanaka", "testtest"
    visit "/reports/#{reports(:report_7).id}"
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
