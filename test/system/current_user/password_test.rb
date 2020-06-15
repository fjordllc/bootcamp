# frozen_string_literal: true

require "application_system_test_case"

class CurrentUser::PasswordTest < ApplicationSystemTestCase
  setup do
    login_user "kimura", "testtest"
    @user = users(:kimura)
  end

  test "update password" do
    visit edit_current_user_path
    click_on "パスワード変更はこちらから"

    within "form[name=password_change]" do
      fill_in "user[password]", with: "newpassword"
      fill_in "user[password_confirmation]", with: "newpassword"
      click_on "更新する"
    end
    assert_text "パスワードを更新しました。"

    find(".test-show-menu").click
    click_link "ログアウト"

    visit login_url
    within "form[name=user_session]" do
      fill_in "user[login]", with: @user.login_name
      fill_in "user[password]", with: "newpassword"
      click_button "ログイン"
    end
    assert_text "ログインしました"
  end
end
