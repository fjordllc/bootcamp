# frozen_string_literal: true

require 'application_system_test_case'

module Announcements
  class NotificationTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'create announcement with notification' do
      visit_with_auth new_announcement_path, 'komagata'
      wait_for_announcement_form
      fill_in 'announcement[title]', with: '公開お知らせ'
      fill_in 'announcement[description]', with: '公開されるお知らせです。'
      assert_difference 'Announcement.count', 1 do
        click_button '作成'
      end
      assert_text 'お知らせを作成しました。'

      assert_user_has_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「公開お知らせ」')
    end

    test 'publish wip announcement with notification' do
      announcement = announcements(:announcement_wip)
      visit_with_auth announcement_path(announcement), 'komagata'
      within '.announcement' do
        click_link '内容修正'
      end
      wait_for_announcement_form
      click_button '公開'
      assert_text 'お知らせを更新しました。'

      assert_user_has_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「wipのお知らせ」')
    end

    test 'update published announcement without notification' do
      announcement = announcements(:announcement1)
      visit_with_auth announcement_path(announcement), 'komagata'
      within '.announcement' do
        click_link '内容修正'
      end
      click_button '公開'

      assert_user_has_no_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「お知らせ1」')
    end

    test 'create wip announcement without notification' do
      visit_with_auth new_announcement_path, 'komagata'
      wait_for_announcement_form
      fill_in 'announcement[title]', with: '仮のお知らせ'
      fill_in 'announcement[description]', with: 'まだWIPです。'
      assert_difference 'Announcement.count', 1 do
        click_button 'WIP'
      end

      assert_user_has_no_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「仮のお知らせ」')
    end

    test 'delete announcement with notification' do
      visit_with_auth '/announcements', 'komagata'
      click_link 'お知らせ作成'
      wait_for_announcement_form
      fill_in 'announcement[title]', with: 'タイトルtest'
      fill_in 'announcement[description]', with: '内容test'

      assert has_no_button? '公開'
      click_button '作成'
      assert_text 'お知らせを作成しました'

      assert_user_has_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「タイトルtest」')

      visit_with_auth '/announcements', 'komagata'
      click_on 'タイトルtest'
      accept_confirm do
        click_link '削除'
      end
      assert_text 'お知らせを削除しました'

      assert_user_has_no_notification(user: users(:hatsuno), kind: Notification.kinds[:announced], text: 'お知らせ「タイトルtest」')
    end

    private

    def wait_for_announcement_form
      assert_selector 'textarea[name="announcement[description]"]:not([disabled])', wait: 20
    end
  end
end
