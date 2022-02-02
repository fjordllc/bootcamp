# frozen_string_literal: true

require 'application_system_test_case'

class Notification::TabsBadgesTest < ApplicationSystemTestCase
  setup do
    Notification.create!(
      message: 'お知らせ',
      kind: 5,
      link: '/notifications/1',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )

    Notification.create!(
      message: 'メンション',
      kind: 2,
      link: '/notifications/2',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )

    Notification.create!(
      message: 'コメント',
      kind: 0,
      link: '/notifications/3',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )

    Notification.create!(
      message: '提出物の確認',
      kind: 1,
      link: '/notifications/4',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )

    Notification.create!(
      message: 'watch中',
      kind: 8,
      link: '/notifications/5',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )
    Notification.create!(
      message: 'フォロー中',
      kind: 13,
      link: '/notifications/6',
      user: users(:sotugyou),
      sender: users(:komagata),
      read: false
    )
  end
  test 'unread badges are displayed' do
    visit_with_auth '/notifications', 'sotugyou'

    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(1) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(2) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(3) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(4) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(5) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(6) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(7) > a > div' do
      assert_selector 'div.page-tabs__item-count.a-notification-count'
    end
  end

  test 'unread badges are not displayed' do
    user = users(:sotugyou)
    user.notifications.unreads.update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

    visit_with_auth '/notifications', 'sotugyou'

    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(1) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(2) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(3) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(4) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(5) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(6) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
    assert_no_selector '#body > div.wrapper > main > div > div > ul > li:nth-child(7) > a > div' do
      assert_no_selector 'div.page-tabs__item-count.a-notification-count'
    end
  end
end
