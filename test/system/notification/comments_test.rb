# frozen_string_literal: true

require "application_system_test_case"

class Notification::CommentsTest < ApplicationSystemTestCase
  test "recieve only one notificaiton if you send two mentions in one comment" do
    login_user "komagata", "testtest"
    visit "/reports/#{reports(:report_1).id}"

    within("#new_comment") do
      fill_in("comment[description]", with: "@machida @machida test")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"

    logout
    login_user "machida", "testtest"

    first(".test-bell").click
    assert_text "komagataさんからメンションがきました。"
    assert_selector ".header-notification-count", text: "1"
  end
end
