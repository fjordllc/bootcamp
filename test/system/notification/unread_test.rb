# frozen_string_literal: true

require "application_system_test_case"

class Notification::UnreadTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing unread notification" do
    visit "/notifications/unread"
    assert_equal "未読の通知 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
