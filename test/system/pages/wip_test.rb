# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class WipTest < ApplicationSystemTestCase
    test 'create page as WIP' do
      visit_with_auth new_page_path, 'kimura'
      within('.form') do
        fill_in('page[title]', with: 'test')
        fill_in('page[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text 'ドキュメントをWIPとして保存しました。'
      assert_text 'ページ編集'
    end

    test 'update page as WIP' do
      visit_with_auth "/pages/#{pages(:page1).id}/edit", 'komagata'
      within('.form') do
        fill_in('page[title]', with: 'test')
        fill_in('page[body]', with: 'test')
      end
      click_button 'WIP'
      assert_text 'ドキュメントをWIPとして保存しました。'
      assert_text 'ページ編集'
    end

    test 'show a WIP Doc on Docs list page' do
      visit_with_auth pages_path, 'kimura'
      assert_text 'WIPのテスト'
      element = all('.card-list-item__rows').find { |component| component.has_text?('WIPのテスト') }
      within element do
        assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
        assert_selector '.a-meta', text: 'Docs作成中'
      end
    end
  end
end
