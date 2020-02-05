# frozen_string_literal: true

require "application_system_test_case"

class PasswordResetTest < ApplicationSystemTestCase
  test "update password" do
    user = users(:kimura)
    user.generate_reset_password_token!
    visit edit_password_reset_url(user.reset_password_token)
    within "form[name=password_reset]" do
      fill_in "user[password]", with: "testpassword"
      fill_in "user[password_confirmation]", with: "testpassword"
      click_button "更新する"
    end
    assert_text "パスワードが変更されました。"

    visit login_url
    within "form[name=user_session]" do
      fill_in "user[login_name]", with: user.login_name
      fill_in "user[password]", with: "testpassword"
      click_button "ログイン"
    end
    assert_text "ログインしました"
  end
end
