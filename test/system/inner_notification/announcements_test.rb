# frozen_string_literal: true

require "application_system_test_case"

class InnerNotification::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @notice_text = "komagataさんからお知らせです。"
    @notice_kind = InnerNotification.kinds["announced"]
    @notified_count = InnerNotification.where(kind: @notice_kind).size
    @reciever_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
  end

  test "all menber recieve a notification when announcement posted" do
    login_user "komagata", "testtest"
    visit "/announcements"
    click_link "お知らせ作成"

    find("input[name='announcement[title]']").set("お知らせです")
    find("textarea[name='announcement[description]']").set("お知らせ内容です")
    click_button "作成"
    logout

    login_user "sotugyou", "testtest"
    first(".test-bell").click
    assert_text @notice_text
    logout

    login_user "komagata", "testtest"
    refute_text @notice_text

    assert_equal(@notified_count + @reciever_count, InnerNotification.where(kind: @notice_kind).size)
  end
end
