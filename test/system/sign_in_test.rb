# frozen_string_literal: true

require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  fixtures :users

  test "sign in" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]",   with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/announcements", current_path
  end

  test "sign in with wrong password" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]",   with: "xxxxxxxx")
    end
    click_button "サインイン"
    assert_equal "/user_sessions", current_path
    assert_text "ユーザー名かパスワードが違います。"
  end
end
