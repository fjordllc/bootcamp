# frozen_string_literal: true

require "application_system_test_case"

class PracticePageCompleteButtonTest < ApplicationSystemTestCase
  test "existence complete button" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/users", current_path
    click_link "プラクティス"
    click_link "PC性能の見方を知る"
    assert has_link? "完了"
    click_link "完了"
    assert_not has_link? "完了"
  end
end
