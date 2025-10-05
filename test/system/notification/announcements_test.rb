# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'お知らせ「タイトル通知用の確認です」'
    @notice_kind = Notification.kinds['announced']
    @notified_count = Notification.where(kind: @notice_kind).size
    @receiver_count = User.where(retired_on: nil).size - 1 # 送信者は除くため-1
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'all member recieve a notification when announcement posted' do
    visit_with_auth '/announcements/new', 'komagata'

    within 'form[name=announcement]' do
      fill_in 'announcement[title]', with: 'タイトル通知用の確認です'
      fill_in 'announcement[description]', with: 'お知らせ内容です'
      choose '全員（退会者を除く）', allow_label_click: true
      click_button '作成'
    end
    assert_text 'お知らせを作成しました。', wait: 10

    sotugyou = users(:sotugyou)
    # 直接Notificationテーブルから確認
    announced_notifications = Notification.where(user: sotugyou, kind: @notice_kind)
    assert announced_notifications.any? { |n| n.message.include?(@notice_text) }, 'sotugyou should have announced notification'

    komagata = users(:komagata)
    komagata_announced_notifications = Notification.where(user: komagata, kind: @notice_kind)
    refute komagata_announced_notifications.any? { |n| n.message.include?(@notice_text) }, 'komagata should not have announced notification'

    expected = @notified_count + @receiver_count
    actual = Notification.where(kind: @notice_kind).size
    assert_equal expected, actual
  end

  test 'announcement to Only Active Users notifies the active users, admins, mentors' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '現役生にのみお知らせtest'
    fill_in 'announcement[description]', with: '内容test'
    find('label', text: '現役生のみ').click

    click_button '作成'
    assert_text 'お知らせを作成しました', wait: 10

    message = 'お知らせ「現役生にのみお知らせtest」'

    notified_users = %w[kimura komagata mentormentaro]
    notified_users.each do |user_name|
      user = users(user_name.to_sym)
      user_notifications = Notification.where(user: user, kind: Notification.kinds[:announced])
      assert user_notifications.any? { |n| n.message.include?(message) }, "#{user_name} should have notification"
    end

    not_notified_users = %w[sotugyou advijirou yameo kensyu]
    not_notified_users.each do |user_name|
      user = users(user_name.to_sym)
      user_notifications = Notification.where(user: user, kind: Notification.kinds[:announced])
      refute user_notifications.any? { |n| n.message.include?(message) }, "#{user_name} should not have notification"
    end
  end

  test 'announcement to Only Job Seekers notifies the job seekers, admins, mentors' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '就活希望者のみお知らせします'
    fill_in 'announcement[description]', with: '合同説明会をやるのでぜひいらしてください！'
    find('label', text: '就職希望者のみ').click

    click_button '作成'
    assert_text 'お知らせを作成しました', wait: 10

    message = 'お知らせ「就活希望者のみお知らせします」'

    notified_users = %w[jobseeker komagata mentormentaro]
    notified_users.each do |user_name|
      user = users(user_name.to_sym)
      user_notifications = Notification.where(user: user, kind: Notification.kinds[:announced])
      assert user_notifications.any? { |n| n.message.include?(message) }, "#{user_name} should have notification"
    end

    not_notified_users = %w[kimura]
    not_notified_users.each do |user_name|
      user = users(user_name.to_sym)
      user_notifications = Notification.where(user: user, kind: Notification.kinds[:announced])
      refute user_notifications.any? { |n| n.message.include?(message) }, "#{user_name} should not have notification"
    end
  end
end
