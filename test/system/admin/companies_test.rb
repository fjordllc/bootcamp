# frozen_string_literal: true

require "application_system_test_case"

class Admin::CompaniesTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show listing companies" do
    visit "/admin/companies"
    assert_equal "会社 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create company" do
    visit "/admin/companies/new"
    within "form[name=company]" do
      fill_in "company[name]", with: "テスト会社"
      fill_in "company[description]", with: "テストの会社です。"
      fill_in "company[website]", with: "https://example.com"
      click_button "登録する"
    end
    assert_text "会社を作成しました。"
  end

  test "update company" do
    visit "/admin/companies/#{companies(:company_1).id}/edit"
    within "form[name=company]" do
      fill_in "company[name]", with: "テスト会社"
      fill_in "company[description]", with: "テストの会社です。"
      fill_in "company[website]", with: "https://example.com"
      click_button "更新する"
    end
    assert_text "会社を更新しました。"
  end

  test "delete company" do
    visit "/admin/companies"
    accept_confirm do
      find("#company_#{companies(:company_1).id} .js-delete").click
    end
    assert_text "会社を削除しました。"
  end
end
