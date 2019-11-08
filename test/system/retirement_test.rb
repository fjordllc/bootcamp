# frozen_string_literal: true

require "application_system_test_case"

class RetirementTest < ApplicationSystemTestCase
  test "user retirementable" do
    login_user "komagata", "testtest"
    visit new_retirement_path
    accept_confirm do
      click_button "退会する"
    end
    assert_text "退会処理が完了しました"
  end

  test "user who does not have kana column retirementable" do
    login_user "kananashi", "testtest"
    visit new_retirement_path
    accept_confirm do
      click_button "退会する"
    end
    assert_text "退会処理が完了しました"
  end
end
