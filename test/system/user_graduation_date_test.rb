# frozen_string_literal: true

require "application_system_test_case"

class UserGraduationDate < ApplicationSystemTestCase
  test "graduation date is displayed" do
    login_user "komagata", "testtest"

    click_link "管理"
    click_link "ユーザー一覧"
    click_link "yamada（Yamada Taro）"
    switch_to_window(windows.last)
    assert_no_text "卒業日時"
    click_link "管理者として情報変更"
    find("#user_graduation", visible: false).click
    click_button "更新する"
    click_link "卒業生"
    click_link "yamada（Yamada Taro）"
    switch_to_window(windows.last)
    assert_text "卒業日時"
  end
end
