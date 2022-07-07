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
      choose '全員', allow_label_click: true
      click_button '作成'
    end
    assert_text 'お知らせを作成しました。'

    visit_with_auth '/notifications', 'sotugyou'

    within first('.card-list-item.is-unread') do
      assert_text @notice_text
    end

    visit_with_auth '/', 'komagata'
    refute_text @notice_text

    expected = @notified_count + @receiver_count
    actual = Notification.where(kind: @notice_kind).size
    assert_equal expected, actual
  end

  test 'announcement notification receive only active users' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '現役生にのみお知らせtest'
    fill_in 'announcement[description]', with: '内容test'
    find('label', text: '現役生のみ').click

    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'komagata'
    assert_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'kimura'
    assert_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'sotugyou'
    assert_no_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'advijirou'
    assert_no_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'yameo'
    assert_no_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'mentormentaro'
    assert_no_text 'お知らせ「現役生にのみお知らせtest」'

    visit_with_auth '/notifications', 'kensyu'
    assert_no_text 'お知らせ「現役生にのみお知らせtest」'
  end

  test 'announcement notifications are only recived by job seekers' do
    visit_with_auth '/announcements', 'machida'
    click_link 'お知らせ作成'
    fill_in 'announcement[title]', with: '就活希望者のみお知らせします'
    fill_in 'announcement[description]', with: '合同説明会をやるのでぜひいらしてください！'
    find('label', text: '就職希望者のみ').click

    click_button '作成'
    assert_text 'お知らせを作成しました'

    visit_with_auth '/notifications', 'komagata'
    assert_text 'お知らせ「就活希望者のみお知らせします」'

    visit_with_auth '/notifications', 'jobseeker'
    assert_text 'お知らせ「就活希望者のみお知らせします」'

    visit_with_auth '/notifications', 'kimura'
    assert_no_text 'お知らせ「就活希望者のみお知らせします」'
  end
end
