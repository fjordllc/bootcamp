require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "sign up" do
    visit "/users/new"
    within "#new_user" do
      fill_in "user[login_name]", with: "testuser"
      fill_in "user[password]", with: "testtest"
      fill_in "user[password_confirmation]", with: "testtest"
      fill_in "user[email]", with: "testuser@example.com"
      fill_in "user[first_name]", with: "Jean"
      fill_in "user[last_name]", with: "Valjean"
    end

    first(".js-nda-action").click
    execute_script "document.querySelector('.nda__action').click();"
    execute_script "document.querySelector('.nda__close').click();"

    click_button "参加する"
    assert_text "サインアップしました。"
  end
end
