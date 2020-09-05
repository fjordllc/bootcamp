# frozen_string_literal: true

require "application_system_test_case"

class Company::ReportsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show listing reports" do
    visit "/companies/#{companies(:company_1).id}/reports"
    assert_equal "FJORD, LLC所属ユーザーの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
