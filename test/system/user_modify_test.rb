# frozen_string_literal: true

require "application_system_test_case"

class UserModifyTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "access by other users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "an error occurs when updating data" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "komagata"
    click_on "更新する"
    assert_text "ユーザー名 はすでに存在します。"
  end

  test "update data and update users" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "hatsuno-1"
    click_on "更新する"
    assert_text "ユーザーを更新しました。"
  end

  test "user is canceled" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "ログインしてください"
  end
end
