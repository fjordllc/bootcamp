# frozen_string_literal: true

require "application_system_test_case"

class AdminModifyUsersTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "accessed by non-administrative users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "an error occurs when updating user-data" do
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    fill_in "user_login_name", with: "komagata"
    click_on "更新する"
    assert_text "ユーザー名 はすでに存在します。"
  end

  test "update user-data and update users" do
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    fill_in "user_login_name", with: "hatsuno-1"
    click_on "更新する"
    assert_text "ユーザーを更新しました。"
  end
end
