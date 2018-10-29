# frozen_string_literal: true

require "application_system_test_case"

class UserModifyTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "本人以外がアクセスする" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "データの更新時にエラーがある" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "komagata"
    click_on "更新する"
    assert_text "ユーザー名 はすでに存在します。"
  end

  test "データを変更してユーザーの更新を行う" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "hatsuno-1"
    click_on "更新する"
    assert_text "ユーザーを更新しました。"
  end

  test "ユーザーが退会する" do
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "ログインしてください"
  end
end
