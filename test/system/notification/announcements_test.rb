# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @notice_text = 'お知らせ「タイトル通知用の確認です」'
    @notice_kind = Notification.kinds['announced']
    @notified_count = Notification.where(kind: @notice_kind).size
    @receiver_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
  end

  test 'all member recieve a notification when announcement posted' do
    visit_with_auth '/announcements/new', 'komagata'

    within 'form[name=announcement]' do
      fill_in 'announcement[title]', with: 'タイトル通知用の確認です'
      fill_in 'announcement[description]', with: 'お知らせ内容です'
      choose '全員にお知らせ', allow_label_click: true
      click_button '作成'
    end

    visit_with_auth '/notifications', 'sotugyou'

    within first('.thread-list-item.is-unread') do
      assert_text @notice_text
    end

    visit_with_auth '/', 'komagata'
    refute_text @notice_text

    expected = @notified_count + @receiver_count
    actual = Notification.where(kind: @notice_kind).size
    assert_equal expected, actual
  end
end
