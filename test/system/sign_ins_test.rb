require "application_system_test_case"

class SignInsTest < ApplicationSystemTestCase
  fixtures :users

  test "sign in" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]",   with: "testtest")
    end
    click_button "サインイン"
    assert_equal current_path, "/users"
  end

  test "sign in with wrong password" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]",   with: "xxxxxxxx")
    end
    click_button "サインイン"
    assert_equal current_path, "/user_sessions"
    assert_text "ユーザー名かパスワードが違います。"
  end
end
