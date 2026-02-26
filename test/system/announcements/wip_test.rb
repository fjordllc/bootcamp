# frozen_string_literal: true

require 'application_system_test_case'

module Announcements
  class WipTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'show WIP message' do
      user = users(:komagata)
      Announcement.create(title: 'test', description: 'test', user:, wip: true)
      visit_with_auth '/announcements', 'kimura'
      assert_selector '.a-list-item-badge'
      assert_text 'お知らせ作成中'
    end

    test 'create a new announcement as wip' do
      visit_with_auth new_announcement_path, 'kimura'
      wait_for_announcement_form
      fill_in 'announcement[title]', with: '仮のお知らせ'
      fill_in 'announcement[description]', with: 'まだWIPです。'
      assert_difference 'Announcement.count', 1 do
        click_button 'WIP'
      end
      assert_text 'お知らせをWIPとして保存しました。'
    end

    test 'general user can copy wip announcement' do
      announcement = announcements(:announcement_wip)
      visit_with_auth announcement_path(announcement), 'kimura'
      within '.announcement' do
        assert_text '複製'
      end
    end

    test 'previous update remains when conflict to update announcement' do
      announcement = announcements(:announcement_wip)
      visit_with_auth announcement_path(announcement), 'komagata'
      click_link '内容修正'
      fill_in 'announcement[description]', with: '先の人が更新'

      Capybara.session_name = :later
      visit_with_auth announcement_path(announcement), 'kimura'
      click_link '内容修正'
      fill_in 'announcement[description]', with: '後の人が更新'

      Capybara.session_name = :default
      click_button 'WIP'
      assert_text 'お知らせをWIPとして保存しました。'

      Capybara.session_name = :later
      click_button 'WIP'
      assert_text '別の人がお知らせを更新していたので更新できませんでした。'
    end
  end
end
