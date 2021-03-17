# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class PagesTest < ApplicationSystemTestCase
  include TagHelper

  setup { login_user 'komagata', 'testtest' }

  test 'GET /pages' do
    visit '/pages'
    assert_equal 'Docs | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_no_selector 'nav.pagination'
  end

  test 'show page' do
    id = pages(:page1).id
    visit "/pages/#{id}"
    assert_equal 'test1 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show edit page' do
    id = pages(:page2).id
    visit "/pages/#{id}/edit"
    assert_equal 'ページ編集 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'page has a comment form ' do
    id = pages(:page1).id
    visit "/pages/#{id}"
    assert_selector '.thread-comment-form'
  end

  test 'title with half-width space' do
    target_page = pages(:page1)
    visit edit_page_path(target_page)
    assert_equal edit_page_path(target_page), current_path
    fill_in 'page[title]', with: '半角スペースを 含んでも 正常なページに 遷移する'
    click_button '内容を保存'
    assert_equal page_path(target_page.reload), current_path
    assert_text 'ページを更新しました'
  end

  test 'add new page' do
    visit new_page_path
    assert_equal new_page_path, current_path
    fill_in 'page[title]', with: '新規ページを作成する'
    fill_in 'page[body]', with: '新規ページを作成する本文です'
    click_button '内容を保存'
    assert_text 'ページを作成しました'
  end

  test 'create page as WIP' do
    login_user 'yamada', 'testtest'
    visit new_page_path
    within('.form') do
      fill_in('page[title]', with: 'test')
      fill_in('page[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text 'ページをWIPとして保存しました。'
  end

  test 'update page as WIP' do
    login_user 'yamada', 'testtest'
    page = pages(:page1)
    visit "/pages/#{page.id}/edit"
    within('.form') do
      fill_in('page[title]', with: 'test')
      fill_in('page[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text 'ページをWIPとして保存しました。'
  end

  test 'search pages by tag' do
    visit pages_url
    click_on '新規ページ'
    tag_list = ['tag1',
                'ドットつき.タグ',
                'ドットが.2つ以上の.タグ',
                '.先頭がドット',
                '最後がドット.']
    within 'form[name=page]' do
      fill_in 'page[title]', with: 'tagのテスト'
      fill_in 'page[body]', with: 'tagをつけます。空白とカンマはタグには使えません。'
      tag_input = find('.ti-new-tag-input')
      tag_list.each do |tag|
        tag_input.set tag
        tag_input.native.send_keys :return
      end
      click_on '内容を保存'
    end
    click_on 'Docs', match: :first

    tag_list.each do |tag|
      assert_text tag
      click_on tag, match: :first
      assert_text 'tagのテスト'
      assert_no_text 'Bootcampの作業のページ'
    end
  end

  test 'update tags without page transitions' do
    login_user 'komagata', 'testtest'
    visit "/pages/#{pages(:page1).id}"
    find('.tag-links__item-edit').click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :return
    click_on '保存'
    wait_for_vuejs
    assert_text '追加タグ'
  end

  test 'administrator can change doc user' do
    admin = users(:machida)
    login_user admin.login_name, 'testtest'
    assert admin.admin?

    page1 = pages(:page1)
    visit "/pages/#{page1.id}/edit"
    assert_equal 'komagata', page1.user.login_name

    within('.form') do
      find('#select2-page_user_id-container').click
      select('kimura', from: 'page[user_id]')
    end

    click_on '保存'
    assert find('.thread__author-icon')[:title].start_with?('kimura')
    assert_equal admin.login_name, find('.thread-header__user-link').text
  end

  test 'non-administrator cannot change doc user' do
    non_admin = users(:kimura)
    login_user non_admin.login_name, 'testtest'
    assert_not non_admin.admin?

    visit "/pages/#{pages(:page1).id}/edit"
    assert_no_selector '.select-users'

    visit '/pages/new'
    assert_no_selector '.select-users'
    within('.form') do
      fill_in('page[title]', with: 'Created by non-admin')
      fill_in('page[body]', with: "非管理者によって作られたDocです。It's created by non-admin.")
    end
    click_on '保存'

    click_on '内容変更'
    assert_no_selector '.select-users'
  end

  test 'doc can relate practice' do
    visit new_page_path
    fill_in 'page[title]', with: 'Docに関連プラクティスを指定'
    fill_in 'page[body]', with: 'Docに関連プラクティスを指定'
    first('.select2-container').click
    find('li.select2-results__option[role="option"]', text: '[UNIX] Linuxのファイル操作の基礎を覚える').click
    click_button '内容を保存'
    assert_text 'Linuxのファイル操作の基礎を覚える'
  end

  test 'alert when enter tag with space on creation page' do
    visit new_page_path

    # この次に assert_alert_when_enter_one_dot_only_tag を追加しても、
    # 空白を入力したalertが発生し、ドットのみのalertが発生するテストにならない
    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on creation page' do
    visit new_page_path

    assert_alert_when_enter_one_dot_only_tag
  end

  test 'alert when enter tag with space on update page' do
    visit "/pages/#{pages(:page1).id}"
    find('.tag-links__item-edit').click

    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag on update page' do
    visit "/pages/#{pages(:page1).id}"
    find('.tag-links__item-edit').click

    assert_alert_when_enter_one_dot_only_tag
  end
end
