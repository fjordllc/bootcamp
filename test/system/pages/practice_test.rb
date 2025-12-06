# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class PracticeTest < ApplicationSystemTestCase
    test 'doc can relate practice' do
      visit_with_auth new_page_path, 'kimura'
      fill_in 'page[title]', with: 'Docに関連プラクティスを指定'
      fill_in 'page[body]', with: 'Docに関連プラクティスを指定'
      first('.choices__inner').click
      find('.choices__item--choice', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
      click_button 'Docを公開'
      assert_text 'Linuxのファイル操作の基礎を覚える'
    end

    test 'link to the practice should appear and work correctly' do
      visit_with_auth new_page_path, 'kimura'
      fill_in 'page[title]', with: 'Docに関連プラクティスを指定'
      fill_in 'page[body]', with: 'Docに関連プラクティスを指定'
      first('.choices__inner').click
      find('.choices__item--choice', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
      click_button 'Docを公開'
      assert_text 'Linuxのファイル操作の基礎を覚える'

      visit pages_path
      within first('.card-list-item-title__title') do
        assert_text 'Docに関連プラクティスを指定'
      end
      within first('.a-meta.is-practice') do
        assert_text 'Linuxのファイル操作の基礎を覚える'
      end
      assert_link 'Linuxのファイル操作の基礎を覚える'
    end

    test 'Check the list of columns on the right of the document' do
      visit_with_auth "/pages/#{pages(:page7).id}", 'kimura'
      assert_link 'OS X Mountain Lionをクリーンインストールする'
      assert_link 'プラクティスに紐付いたDocs'
      assert_link '全て見る'
    end
  end
end
