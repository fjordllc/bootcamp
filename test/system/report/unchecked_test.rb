# frozen_string_literal: true

require "application_system_test_case"

class Report::UncheckedTest < ApplicationSystemTestCase
  setup { login_user "hatsuo", "testtest" }

  test "show listing unchecked reports" do
    login_user "komagata", "testtest"
    visit "/reports/unchecked"
    assert_equal "未チェックの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "non-staff user can not see listing unchecked reports" do
    visit "/reports/unchecked"
    assert_text "管理者・アドバイザー・メンターとしてログインしてください"
  end

  test "mentor can see a button to open all unchecked reports" do
    login_user "komagata", "testtest"
    visit "/reports/unchecked"
    assert_button "未チェックの日報を一括で開く"
  end
end
