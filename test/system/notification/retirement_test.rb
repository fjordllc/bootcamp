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
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item') do
      assert_no_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end

    visit_with_auth new_retirement_path, 'kimura'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    visit_with_auth notifications_path, 'komagata'
    find('#notifications.loaded', wait: 10)
    within first('.card-list-item.is-unread') do
      assert_selector '.card-list-item-title__link-label', text: '😢 kimuraさんが退会しました。'
    end
  end

  test 'notify admins when three months after retirement' do
    mock_log = []
    stub_info = proc { |i| mock_log << i }
    Rails.logger.stub(:info, stub_info) do
      visit_with_auth '/scheduler/daily/after_retirement', 'komagata'
      visit '/notifications'
      assert_text 'yameoさんが退会してから3カ月が経過しました。'
      assert_text 'kensyuowataさんが退会してから3カ月が経過しました。'
    end

    assert_match 'Message to Discord.', mock_log.to_s
  end
end
