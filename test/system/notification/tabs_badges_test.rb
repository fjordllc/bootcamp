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

    within first('.page-tabs__item:nth-child(1)') do
      find('div', text: '10')
    end
    within first('.page-tabs__item:nth-child(2)') do
      find('div', text: '2')
    end
    within first('.page-tabs__item:nth-child(3)') do
      find('div', text: '2')
    end
    within first('.page-tabs__item:nth-child(4)') do
      find('div', text: '3')
    end
    within first('.page-tabs__item:nth-child(5)') do
      find('div', text: '2')
    end
    within first('.page-tabs__item:nth-child(6)') do
      find('div', text: '1')
    end
    within first('.page-tabs__item:nth-child(7)') do
      find('div', text: '1')
    end
  end

  test 'unread badges are not displayed' do
    user = users(:sotugyou)
    user.notifications.unreads.update_all(read: true) # rubocop:disable Rails/SkipsModelValidations

    visit_with_auth '/notifications', 'sotugyou'

    within all('.page-tabs__item')[0] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[1] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[2] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[3] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[4] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[5] do
      assert_no_selector '.page-tabs__item-count'
    end
    within all('.page-tabs__item')[6] do
      assert_no_selector '.page-tabs__item-count'
    end
  end
end
