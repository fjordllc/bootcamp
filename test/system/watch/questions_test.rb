# frozen_string_literal: true

require "application_system_test_case"

class Watch::QuestionsTest < ApplicationSystemTestCase
  test "success question watching cancel" do
    setup do
      watches(:question1_watch_kimura)
    end

    login_user "kimura", "testtest"
    visit "/questions/#{questions(:question_1).id}"

    click_on "Unwatch"
    assert_text "ウォッチを止めました"
  end
end
