# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @notice_text = 'お知らせ 「タイトル通知用の確認です」'
    @notice_kind = Notification.kinds['announced']
    @notified_count = Notification.where(kind: @notice_kind).size
    @receiver_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
  end

  test 'all menber recieve a notification when announcement posted' do
    visit_with_auth '/announcements', 'komagata'
    click_link 'お知らせ作成'

    find("input[name='announcement[title]']").set('タイトル通知用の確認です')
    find("textarea[name='announcement[description]']").set('お知らせ内容です')
    find("input[value='all']", { visible: false }).set(true)
    click_button '作成'
    logout

    visit_with_auth '/', 'sotugyou'
    open_notification
    assert_equal @notice_text, notification_message
    logout

    visit_with_auth '/', 'komagata'
    refute_text @notice_text

    assert_equal(@notified_count + @receiver_count, Notification.where(kind: @notice_kind).size)
  end
end
