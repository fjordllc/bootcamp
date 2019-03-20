# frozen_string_literal: true

require "application_system_test_case"

class CurrentUserTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "update user" do
    visit "/current_user/edit"
    within "form[name=user]" do
      fill_in "user[login_name]", with: "testuser"
      page.execute_script("window.scroll(0,10000);")
      click_on "更新する"
    end
    assert_text "ユーザー情報を更新しました。"
  end
end
