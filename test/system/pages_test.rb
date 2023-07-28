# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class PagesTest < ApplicationSystemTestCase
  include TagHelper

  setup do
    @raise_server_errors = Capybara.raise_server_errors
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'GET /pages' do
    visit_with_auth '/pages', 'kimura'
    assert_equal 'Docs | FBC', title
    assert_no_selector 'nav.pagination'
  end

  test 'show page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    assert_equal 'test1 | FBC', title
  end

  test 'show edit page' do
    visit_with_auth "/pages/#{pages(:page2).id}/edit", 'kimura'
    assert_equal 'ページ編集 | FBC', title
  end

  test 'page has a comment form ' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    assert_selector '.thread-comment-form'
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

  test 'add new page' do
    visit_with_auth new_page_path, 'kimura'
    assert_equal new_page_path, current_path
    fill_in 'page[title]', with: '新規Docを作成する'
    fill_in 'page[body]', with: '新規Docを作成する本文です'
    click_button 'Docを公開'
    assert_text 'ドキュメントを作成しました。'
    assert_text 'Watch中'
  end

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
    visit_with_auth "/pages/#{pages(:page1).id}/edit", 'kimura'
    within('.form') do
      fill_in('page[title]', with: 'test')
      fill_in('page[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text 'ドキュメントをWIPとして保存しました。'
    assert_text 'ページ編集'
  end

  test 'destroy page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'komagata'

    accept_confirm do
      click_link '削除する'
    end

    assert_text 'ドキュメントを削除しました。'
  end

  test 'administrator can change doc user' do
    visit_with_auth "/pages/#{pages(:page1).id}/edit", 'komagata'

    within('.form') do
      find('#select2-page_user_id-container').click
      select('kimura', from: 'page[user_id]')
      find('.select-users').click
    end

    click_button '内容を更新'
    within '.a-meta.is-creator' do
      assert find('.thread-header__user-icon')[:title].start_with?('kimura')
    end
    within '.a-meta.is-updater' do
      assert_equal 'komagata', find('.a-user-name').text
    end
  end

  test 'non-administrator cannot change doc user' do
    visit_with_auth "/pages/#{pages(:page1).id}/edit", 'kimura'
    assert_no_selector '.select-users'

    visit '/pages/new'
    assert_no_selector '.select-users'
    within('.form') do
      fill_in('page[title]', with: 'Created by non-admin')
      fill_in('page[body]', with: "非管理者によって作られたDocです。It's created by non-admin.")
    end
    click_on 'Docを公開'

    click_on '内容変更'
    assert_no_selector '.select-users'
  end

  test 'doc can relate practice' do
    visit_with_auth new_page_path, 'kimura'
    fill_in 'page[title]', with: 'Docに関連プラクティスを指定'
    fill_in 'page[body]', with: 'Docに関連プラクティスを指定'
    first('.select2-container').click
    find('li.select2-results__option[role="option"]', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
    click_button 'Docを公開'
    assert_text 'Linuxのファイル操作の基礎を覚える'
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

  test 'show comment count' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    assert_selector '#comment_count', text: 0

    fill_in 'new_comment[description]', with: 'コメント数表示のテストです。'
    click_button 'コメントする'

    visit current_path
    assert_selector '#comment_count', text: 1
  end

  test 'show last updated user icon' do
    visit_with_auth "/pages/#{pages(:page7).id}", 'hajime'
    within '.a-meta.is-updater' do
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
    end
  end

  test 'show a WIP Doc on Docs list page' do
    visit_with_auth pages_path, 'kimura'
    assert_text 'WIPのテスト'
    element = all('.card-list-item__rows').find { |component| component.has_text?('WIPのテスト') }
    within element do
      assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
      assert_selector '.a-meta', text: 'Doc作成中'
    end
  end

  test 'show 404 page when accessed with slug does not exist in Docs' do
    Capybara.raise_server_errors = false

    slug = 'help12345'
    visit_with_auth "/pages/#{slug}", 'kimura'
    assert_text 'ActiveRecord::RecordNotFound'
  end

  test 'link to the practice should appear and work correctly' do
    visit_with_auth new_page_path, 'kimura'
    fill_in 'page[title]', with: 'Docに関連プラクティスを指定'
    fill_in 'page[body]', with: 'Docに関連プラクティスを指定'
    first('.select2-container').click
    find('li.select2-results__option[role="option"]', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
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

  test 'notify to chat after create a page' do
    visit_with_auth new_page_path, 'kimura'
    within('.form') do
      fill_in('page[title]', with: 'test')
      fill_in('page[body]', with: 'test')
    end

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button 'Docを公開'
    end

    assert_text 'ドキュメントを作成しました。'
    assert_text 'Watch中'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'notify to chat after update a page' do
    target_page = pages(:page5)
    visit_with_auth edit_page_path(target_page), 'kimura'

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '内容を更新'
    end

    assert_text 'ドキュメントを更新しました。'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'Check the list of columns on the right of the document' do
    visit_with_auth "/pages/#{pages(:page7).id}", 'kimura'
    assert_link 'OS X Mountain Lionをクリーンインストールする'
    assert_link 'プラクティスに紐付いたDocs'
    assert_link '全て見る'
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
    click_button '内容を更新'

    assert_text 'ドキュメントを更新しました。'
    assert has_field?('announcement[title]', with: 'ドキュメント「お知らせにチェックを入れてWIP状態から新規Docを作成」を公開しました。')
    assert_text '「お知らせにチェックを入れてWIP状態から新規Docを作成」の本文です。'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_page_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
