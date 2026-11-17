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
  end
end
