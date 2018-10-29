# frozen_string_literal: true

require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "sign up" do
    visit new_user_path
    within "#new_user" do
      filler
    end

    click_on "参加する"
    assert_text "サインアップしました。"
  end

  test "faild to sign up" do
    visit new_user_path
    within "#new_user" do
      filler
      fill_in "user[login_name]", with: "komagata"
    end

    click_on "参加する"
    assert_text "ユーザー名 はすでに存在します。"
  end

  private
    def filler
      fill_in "user[login_name]", with: "testuser"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      fill_in "user[email]", with: "testuser@example.com"
      fill_in "user[first_name]", with: "Jean"
      fill_in "user[last_name]", with: "Valjean"
      first(".js-nda-action").click
      execute_script "document.querySelector('.nda__action').click();"
      execute_script "document.querySelector('.nda__close').click();"
    end
end
