# frozen_string_literal: true

require 'application_system_test_case'

class Notification::HibernationTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify admins and mentors when a student hibernate' do
    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: 'kimuraさんが休会しました。'
    end

    visit_with_auth new_hibernation_path, 'kimura'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会処理が完了しました'

    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: 'kimuraさんが休会しました。'
    end
  end

  test 'notify admins and mentors when a trainee hibernate' do
    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: 'kensyuさんが休会しました。'
    end

    visit_with_auth new_hibernation_path, 'kensyu'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会処理が完了しました'

    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: 'kensyuさんが休会しました。'
    end
  end

  test 'notify admins and mentors when a adviser hibernate' do
    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: 'senpaiさんが休会しました。'
    end

    visit_with_auth new_hibernation_path, 'senpai'
    fill_in 'hibernation[scheduled_return_on]', with: Time.current.next_month
    fill_in 'hibernation[reason]', with: 'テストのため'
    accept_confirm do
      click_button '休会する'
    end
    assert_text '休会処理が完了しました'

    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: 'senpaiさんが休会しました。'
    end
  end
end
