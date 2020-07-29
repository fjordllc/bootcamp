# frozen_string_literal: true

require "application_system_test_case"

class Report::UncheckedTest < ApplicationSystemTestCase
  setup { login_user "hatsuo", "testtest" }

  test "show listing unchecked reports" do
    visit "/reports/unchecked"
    assert_equal "未チェックの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "non-mentor can not see a button to open all unchecked reports" do
    visit "/reports/unchecked"
    assert_no_button "未チェックの日報を一括で開く"
  end

  test "mentor can see a button to open all unchecked reports" do
    login_user "komagata", "testtest"
    visit "/reports/unchecked"
    assert_button "未チェックの日報を一括で開く"
  end
end
