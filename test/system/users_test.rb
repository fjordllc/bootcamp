# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "show profile" do
    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_equal "hatsunoのプロフィール | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "access by other users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "an error occurs when updating data" do
    login_user "hatsuno", "testtest"
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "komagata"
    click_on "更新する"
    assert_text "ユーザー名はすでに存在します"
  end

  test "update data and update users" do
    login_user "hatsuno", "testtest"
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    fill_in "user_login_name", with: "hatsuno-1"
    click_on "更新する"
    assert_text "ユーザーを更新しました。"
  end

  test "user is canceled" do
    login_user "hatsuno", "testtest"
    user = users(:hatsuno)
    visit edit_user_path(user.id)
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "ログインしてください"
  end

  test "graduation date is displayed" do
    login_user "komagata", "testtest"

    visit "/users/#{users(:yamada).id}"
    assert_no_text "卒業日"

    visit "/users/#{users(:tanaka).id}"
    assert_text "卒業日"
  end

  test "retired date is displayed" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:yameo).id}"
    assert_text "リタイア日"
    visit "/users/#{users(:tanaka).id}"
    assert_no_text "リタイア日"
  end

  test "user list corresponding to selected status is displayed" do
    login_user "komagata", "testtest"

    assert_text "ユーザー"
    click_link "ユーザー"

    assert_equal 5, all(".tab-nav__item-link").length
    assert_equal 3, all(".users-item__inner").length
    assert_text "yamada"
    assert_text "kimura"
    assert_text "hatsuno"
    assert_text "hajime"


    assert_text "卒業生"
    click_link "卒業生"
    assert_equal 1, all(".users-item__inner").length
    assert_text "tanaka"

    assert_text "アドバイザー"
    click_link "アドバイザー"
    assert_equal 1, all(".users-item__inner").length
    assert_text "mineo"

    assert_text "全員"
    click_link "全員"
    assert_equal 9, all(".users-item__inner").length
    assert_text "yameo"
  end
end
