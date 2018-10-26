# frozen_string_literal: true

require "application_system_test_case"

class Notification::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @notice_text = "komagataさんからお知らせです！"
    @notified_count = Notification.where(kind: 5).size
    @reciever_count = User.where(retire: false).size - 1 # 送信者は除くため-1
  end

  test "all menber recieve a notification when announcement posted" do
    login_user "komagata", "testtest"
    count = "nav.pagination"
    visit "/announcements"
    click_link "お知らせの新規作成"

    find("input[name='announcement[title]']").set("お知らせです")
    find("textarea[name='announcement[description]']").set("お知らせ内容です")
    click_button "作成"
    logout

    login_user "tanaka", "testtest"
    first(".test-bell").click
    assert_text @notice_text
    logout

    login_user "komagata", "testtest"
    refute_text @notice_text

    assert_equal(@notified_count + @reciever_count, Notification.where(kind: 5).size)
  end
end
