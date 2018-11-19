# frozen_string_literal: true

require "application_system_test_case"

class Report::UncheckedTest < ApplicationSystemTestCase
  setup { login_user "hatsuo", "testtest" }

  test "show listing unchecked reports" do
    visit "/reports/unchecked"
    assert_equal "未チェックの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
