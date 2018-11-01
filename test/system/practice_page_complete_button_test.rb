# frozen_string_literal: true

require "application_system_test_case"

class PracticePageCompleteButtonTest < ApplicationSystemTestCase
  test "existence complete button" do
    login_user "komagata", "testtest"
    visit "/practices/#{practices(:practice_3).id}"
    assert has_link? "完了"
    click_link "完了"
    assert_not has_link? "完了"
  end
end
