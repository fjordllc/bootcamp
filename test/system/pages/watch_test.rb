# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class WatchTest < ApplicationSystemTestCase
    # 作成者を変えたときに作成者が Watch 中になることは
    # test/integration/page_watchers_test.rb で確かめる。
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
      assert_text 'ドキュメントをWIPとして保存しました。'
      visit page_path(pages(:page2))
      assert_text 'Watch中'
    end
  end
end
