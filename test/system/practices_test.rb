# frozen_string_literal: true

require "application_system_test_case"

class PracticesTest < ApplicationSystemTestCase
  test "finish a practice" do
    login_user "komagata", "testtest"
    visit "/practices/#{practices(:practice_1).id}"
    find("#js-complete").click
    assert_not has_link? "完了"
  end
end
