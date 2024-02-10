# frozen_string_literal: true

require 'application_system_test_case'

class NotificationsBellTest < ApplicationSystemTestCase
  test 'Unread and All tubs filter their target notifications' do
    visit_with_auth '/notifications', 'komagata'
    click_link '全て既読にする'

    Notification.create(message: 'お知らせのテスト通知',
                        kind: 'announced',
                        link: '/announcements/1',
                        user: users(:komagata),
                        sender: users(:machida))
    Notification.create(message: 'コメントのテスト通知',
                        kind: 'came_comment',
                        link: '/reports/1',
                        user: users(:komagata),
                        sender: users(:machida))
    visit_with_auth '/notifications?status=unread&target=announcement', 'komagata'
    click_link 'お知らせを既読にする'

    visit '/'
    find('.header-links__link.test-show-notifications').click
    assert_selector('.test-notification-message', text: 'コメントのテスト通知')
    assert_no_selector('.test-notification-message', text: 'お知らせのテスト通知')

    find('.pill-nav__item-link.w-full', text: '全て').click
    assert_selector('.test-notification-message', text: 'コメントのテスト通知')
    assert_selector('.test-notification-message', text: 'お知らせのテスト通知')
  end

  test "No notification is displayed if an user doesn't have target notifications of a selected tab" do
    users(:kimura).notifications.destroy_all
    visit_with_auth '/', 'kimura'

    find('.header-links__link.test-show-notifications').click
    assert_selector('.o-empty-message.mb-8 .o-empty-message__text', text: '未読の通知はありません')
    find('.pill-nav__item-link.w-full', text: '全て').click
    assert_selector('.o-empty-message.mb-8 .o-empty-message__text', text: '通知はありません')
  end
end
