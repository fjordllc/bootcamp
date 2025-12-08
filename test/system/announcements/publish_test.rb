# frozen_string_literal: true

require 'application_system_test_case'

module Announcements
  class PublishTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'announcement creator can publish wip announcement' do
      announcement = announcements(:announcement_wip_not_mentor_or_admin)
      visit_with_auth announcement_path(announcement), 'kimura'
      within '.announcement' do
        click_link '内容修正'
      end
      assert has_button? '公開'
    end

    test "general user can't publish other user's wip announcement" do
      announcement = announcements(:announcement_wip_not_mentor_or_admin)
      visit_with_auth announcement_path(announcement), 'hajime'
      within '.announcement' do
        click_link '内容修正'
      end
      assert has_no_button? '公開'
    end

    test 'admin user can publish wip announcement' do
      announcement = announcements(:announcement_wip)
      visit_with_auth announcement_path(announcement), 'komagata'
      within '.announcement' do
        click_link '内容修正'
      end
      assert has_no_button? '作成', exact: true
      assert has_button? '公開'
    end

    test 'admin user can publish submitted announcement' do
      announcement = announcements(:announcement1)
      visit_with_auth announcement_path(announcement), 'komagata'
      within '.announcement' do
        click_link '内容修正'
      end
      assert has_no_button? '作成', exact: true
      assert has_button? '公開'
    end

    test 'general user can publish submitted announcement' do
      announcement = announcements(:announcement1)
      visit_with_auth announcement_path(announcement), 'kimura'
      within '.announcement' do
        click_link '内容修正'
      end
      assert has_no_button? '作成'
      assert has_button? '公開'
    end

    test 'watching is automatically displayed when admin create new announcement' do
      visit_with_auth new_announcement_path, 'komagata'
      wait_for_announcement_form
      fill_in 'announcement[title]', with: 'Watch中になるかのテスト'
      fill_in 'announcement[description]', with: 'お知らせ作成時にWatch中になるかのテストです。'
      click_button '作成'

      assert_text 'お知らせを作成しました。'
      assert_text 'Watch中'
    end
  end
end
