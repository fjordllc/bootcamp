# frozen_string_literal: true

require "application_system_test_case"

class User::ReportsTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing reports" do
    visit "/users/#{users(:hatsuno).id}/reports"
    assert_equal "hatsunoの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
