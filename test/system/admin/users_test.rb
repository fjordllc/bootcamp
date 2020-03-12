# frozen_string_literal: true

require "application_system_test_case"

class Admin::UsersTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show listing users" do
    visit "/admin/users?target=all"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing students" do
    visit "/admin/users"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing inactive users" do
    visit "/admin/users?target=inactive"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing retired users" do
    visit "/admin/users?target=retired"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing graduated users" do
    visit "/admin/users?target=graduate"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing advisers" do
    visit "/admin/users?target=adviser"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing mentors" do
    visit "/admin/users?target=mentor"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show listing trainee" do
    visit "/admin/users?target=trainee"
    assert_equal "ユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    assert_text "kensyu（Kensyu Seiko）"
  end

  test "accessed by non-administrative users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "an error occurs when updating user-data" do
    user = users(:hatsuno)
    visit "/admin/users/#{user.id}/edit"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "komagata"
      click_on "更新する"
    end
    assert_text "アカウントはすでに存在します"
  end

  test "update user" do
    user = users(:hatsuno)
    visit "/admin/users/#{user.id}/edit"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "hatsuno-1"
      click_on "更新する"
    end
    assert_text "ユーザー情報を更新しました。"
  end

  test "delete user" do
    user = users(:kimura)
    visit admin_users_path(target: "student")
    click_on "delete-#{user.id}"
    page.driver.browser.switch_to.alert.accept
    assert_text "#{user.full_name} さんを削除しました。"
  end

  test "hide input for graduation date when unchecked" do
    user = users(:hatsuno)
    visit "/admin/users/#{user.id}/edit"
    assert has_unchecked_field?("graduation_checkbox", visible: false)
    assert_no_selector "#user_graduated_on"
  end

  test "show input for graduation date when checked" do
    user = users(:hatsuno)
    visit "/admin/users/#{user.id}/edit"
    check "graduation_checkbox", allow_label_click: true
    assert_selector "#user_graduated_on"
  end

  test "show input for graduation date if user is graudated" do
    user = users(:sotugyou)
    visit "/admin/users/#{user.id}/edit"
    assert has_checked_field?("graduation_checkbox", visible: false)
    assert has_field?("user_graduated_on", with: user.graduated_on.to_s)
  end

  test "reset value of graduation date when unchecked" do
    user = users(:sotugyou)
    visit "/admin/users/#{user.id}/edit"
    uncheck "graduation_checkbox", allow_label_click: true
    assert has_unchecked_field?("graduation_checkbox", visible: false)
    check "graduation_checkbox", allow_label_click: true
    assert has_field?("user_graduated_on", with: "")
  end
end
