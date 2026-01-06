# frozen_string_literal: true

require 'application_system_test_case'

module Pages
  class NotificationTest < ApplicationSystemTestCase
    test 'create a page' do
      visit_with_auth new_page_path, 'kimura'
      within('.form') do
        fill_in('page[title]', with: 'test')
        fill_in('page[body]', with: 'test')
      end

      click_button 'Docを公開'

      assert_text 'ドキュメントを作成しました。'
      assert_text 'Watch中'
    end

    test 'publish a WIP page' do
      target_page = pages(:page5)
      visit_with_auth edit_page_path(target_page), 'kimura'

      click_button 'Docを公開'

      assert_text 'ドキュメントを作成しました。'
    end

    test 'check the box for notification to publish the document' do
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'お知らせにチェックを入れて新規Docを作成'
      fill_in 'page[body]', with: '「お知らせにチェックを入れて新規Docを作成」の本文です。'
      check 'ドキュメント公開のお知らせを書く', allow_label_click: true
      click_button 'Docを公開'

      assert_text 'ドキュメントを作成しました。'
      assert has_field?('announcement[title]', with: 'ドキュメント「お知らせにチェックを入れて新規Docを作成」を公開しました。')
      assert_text '「お知らせにチェックを入れて新規Docを作成」の本文です。'
    end

    test 'publish a new document from WIP after checking the create notification box.' do
      visit_with_auth new_page_path, 'komagata'
      fill_in 'page[title]', with: 'お知らせにチェックを入れてWIP状態から新規Docを作成'
      fill_in 'page[body]', with: '「お知らせにチェックを入れてWIP状態から新規Docを作成」の本文です。'
      click_button 'WIP'

      check 'ドキュメント公開のお知らせを書く', allow_label_click: true
      click_button 'Docを公開'

      assert_text 'ドキュメントを作成しました。'
      assert has_field?('announcement[title]', with: 'ドキュメント「お知らせにチェックを入れてWIP状態から新規Docを作成」を公開しました。')
      assert_text '「お知らせにチェックを入れてWIP状態から新規Docを作成」の本文です。'
    end
  end
end
