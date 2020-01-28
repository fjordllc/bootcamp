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
    click_button "ログイン"
    assert_equal "/", current_path
  end

  test "sign in with wrong password" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]",   with: "xxxxxxxx")
    end
    click_button "ログイン"
    assert_equal "/user_sessions", current_path
    assert_text "ユーザー名かパスワードが違います。"
  end

  test "sign in with retire account" do
    logout
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "yameo")
      fill_in("user[password]",   with: "yameo@example.com")
    end
    click_button "ログイン"
    assert_equal "/user_sessions", current_path
    assert_text "ユーザー名かパスワードが違います。"

    visit "/users"
    assert_equal root_path, current_path
  end
end
