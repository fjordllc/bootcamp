# frozen_string_literal: true

require 'application_system_test_case'

class Notification::RetirementTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify admins and mentors when a user retire' do
    visit_with_auth notifications_path, 'komagata'
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end

    visit_with_auth notifications_path, 'machida'
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end

    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    visit_with_auth notifications_path, 'komagata'
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end

    visit_with_auth notifications_path, 'machida'
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end
  end
end
