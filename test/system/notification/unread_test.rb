# frozen_string_literal: true

require "application_system_test_case"

class Notification::UnreadTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing unread notification" do
    visit "/notifications/unread"
    assert_equal "未読の通知 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "non-mentor can not see a button to open all unread notifications" do
    visit "/notifications/unread"
    assert_no_button "未読の通知を一括で開く"
  end

  test "mentor can see a button to open to open all unread notifications" do
    login_user "komagata", "testtest"
    visit "/notifications/unread"
    assert_button "未読の通知を一括で開く"
  end
end
