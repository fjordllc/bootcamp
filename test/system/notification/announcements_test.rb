# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::AnnouncementsTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'お知らせ「タイトル通知用の確認です」'
    @notice_kind = Notification.kinds['announced']
    @notified_count = Notification.where(kind: @notice_kind).size
    @receiver_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 対象ごとの届き先は test/integration/announcement_notifications_test.rb で確かめる。
  test 'all member recieve a notification when announcement posted' do
    visit_with_auth '/announcements/new', 'komagata'

    within 'form[name=announcement]' do
      fill_in 'announcement[title]', with: 'タイトル通知用の確認です'
      fill_in 'announcement[description]', with: 'お知らせ内容です'
      choose '全員（退会者を除く）', allow_label_click: true
      click_button '作成'
    end
    assert_text 'お知らせを作成しました。'

    assert_user_has_notification(user: users(:sotugyou), kind: @notice_kind, text: @notice_text)
    assert_user_has_no_notification(user: users(:komagata), kind: @notice_kind, text: @notice_text)

    expected = @notified_count + @receiver_count
    actual = Notification.where(kind: @notice_kind).size
    assert_equal expected, actual
  end
end
