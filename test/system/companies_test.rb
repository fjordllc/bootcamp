# frozen_string_literal: true

require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "GET /companies" do
    visit "/companies"
    assert_equal "企業一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show company information" do
    visit "/companies/#{companies(:company_1).id}"
    assert_equal "FJORD, LLCの会社情報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show link to website if company has" do
    visit "/companies/#{companies(:company_1).id}"
    within ".company_website" do
      assert_link "FJORD, LLC", href: "https://fjord.jp"
    end
  end
end
