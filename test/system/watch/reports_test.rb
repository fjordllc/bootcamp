# frozen_string_literal: true

require "application_system_test_case"

class Watch::ReportsTest < ApplicationSystemTestCase
  test "success report watching cancel" do
    setup do
      watches(:report1_watch_kimura)
    end

    login_user "kimura", "testtest"
    visit "/reports/#{reports(:report_1).id}"

    click_on "Unwatch"
    assert_text "ウォッチを止めました"
  end
end
