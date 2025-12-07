# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class CrudTest < ApplicationSystemTestCase
    test 'add new page' do
      visit_with_auth new_page_path, 'kimura'
      assert_equal new_page_path, current_path
      fill_in 'page[title]', with: '新規Docを作成する'
      fill_in 'page[body]', with: '新規Docを作成する本文です'
      click_button 'Docを公開'
      assert_text 'ドキュメントを作成しました。'
      assert_text 'Watch中'
    end

    test 'destroy page' do
      visit_with_auth "/pages/#{pages(:page1).id}", 'komagata'

      accept_confirm do
        click_link '削除する'
      end

      assert_text 'ドキュメントを削除しました。'
    end

    test 'title with half-width space' do
      target_page = pages(:page1)
      visit_with_auth edit_page_path(target_page), 'kimura'
      assert_equal edit_page_path(target_page), current_path
      fill_in 'page[title]', with: '半角スペースを 含んでも 正常なページに 遷移する'
      click_button '内容を更新'
      assert_equal page_path(target_page.reload), current_path
      assert_text 'ドキュメントを更新しました。'
    end

    test 'add new page with slug and visit page' do
      slug = 'test-page-slug1'
      visit_with_auth new_page_path, 'kimura'
      fill_in 'page[title]', with: 'ページタイトル'
      fill_in 'page[slug]', with: slug
      fill_in 'page[body]', with: 'slug付きテストページの本文'
      click_button 'Docを公開'
      visit "/pages/#{slug}"
      assert_text 'slug付きテストページの本文'
    end
  end
end
