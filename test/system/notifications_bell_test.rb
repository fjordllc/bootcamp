# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsBellTest < ApplicationSystemTestCase
  test 'Unread and All tabs filter their target notifications' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    Notification.create(
      message: 'お知らせのテスト通知',
      kind: 'announced',
      link: '/announcements/1',
      user: users(:komagata),
      sender: users(:machida)
    )
    Notification.create(
      message: 'コメントのテスト通知',
      kind: 'came_comment',
      link: '/reports/1',
      user: users(:komagata),
      sender: users(:machida)
    )
    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    click_link 'お知らせを既読にする'

    visit '/'
    find('.header-links__link.test-show-notifications').click
    assert_selector('.test-notification-message', text: 'コメントのテスト通知')
    assert_no_selector('.test-notification-message', text: 'お知らせのテスト通知')
    assert has_link?('全ての未読通知一覧へ', href: '/notifications?status=unread')
    assert has_link?('全て既読にする', href: '/notifications/allmarks')
    assert_button '全て別タブで開く'

    find('.pill-nav__item-link.w-full', text: '全て').click
    assert_selector('.test-notification-message', text: 'コメントのテスト通知')
    assert_selector('.test-notification-message', text: 'お知らせのテスト通知')
    assert has_link?('全ての通知一覧へ', href: '/notifications')
  end

  test "No notification is displayed if an user doesn't have target notifications of a selected tab" do
    users(:kimura).notifications.destroy_all
    visit_with_auth '/', 'kimura'

    find('.header-links__link.test-show-notifications').click
    assert_selector('.a-empty-message.mb-8 .a-empty-message__text', text: '未読の通知はありません')
    assert has_link?('通知一覧へ', href: '/notifications')
    find('.pill-nav__item-link.w-full', text: '全て').click
    assert_selector('.a-empty-message.mb-8 .a-empty-message__text', text: '通知はありません')
  end

  test 'Up to 10 notifications are displayed in an All tab' do
    10.times do |n|
      Notification.create(
        message: "machidaさんからメンションが届きました#{n}",
        kind: 'mentioned',
        link: "/reports/#{n}",
        user: users(:komagata),
        sender: users(:machida)
      )
    end
    Notification.create(
      message: '1番新しい通知',
      created_at: '2040-01-18 06:06:42',
      kind: 'mentioned',
      link: '/reports/20400118',
      user: users(:komagata),
      sender: users(:machida)
    )

    visit_with_auth '/', 'komagata'
    find('.header-links__link.test-show-notifications').click
    find('.pill-nav__item-link.w-full', text: '全て').click
    assert_selector('.test-notification-message', text: '1番新しい通知')
    assert_equal 10, all('.test-notification-message').size
  end
end
