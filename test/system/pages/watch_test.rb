# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class WatchTest < ApplicationSystemTestCase
    test 'non-author docs editor becomes watcher' do
      # 編集前にWatch中になってないかチェック(作成者を除くDocs編集者)
      editor = 'machida'
      visit_with_auth page_path(pages(:page1)), editor
      assert_text 'Watch'
      visit page_path(pages(:page2))
      assert_text 'Watch'

      visit edit_page_path(pages(:page1))
      click_button '内容を更新'
      assert_text 'ドキュメントを更新しました'
      assert_text 'Watch中'

      visit edit_page_path(pages(:page2))
      click_button 'WIP'
      visit page_path(pages(:page2))
      assert_text 'Watch中'
    end

    test 'author becomes watcher' do
      author = 'kimura'
      # 編集前にWatch中になってないかチェック
      visit_with_auth page_path(pages(:page1)), author
      assert_text 'Watch'
      visit page_path(pages(:page2))
      assert_text 'Watch'

      logout

      # 編集者もwatch中になるため、作者と編集者を別にする
      editor = 'machida'
      visit_with_auth edit_page_path(pages(:page1)), editor

      within('.form') do
        find('#select2-page_user_id-container').click
        select(author, from: 'page[user_id]')
      end
      click_button '内容を更新'

      visit edit_page_path(pages(:page2))

      within('.form') do
        find('#select2-page_user_id-container').click
        select(author, from: 'page[user_id]')
      end
      click_button 'WIP'

      logout

      visit_with_auth page_path(pages(:page1)), author
      assert_text 'Watch中'
      visit page_path(pages(:page2))
      assert_text 'Watch中'
    end
  end
end
