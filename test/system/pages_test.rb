# frozen_string_literal: true

require 'application_system_test_case'

class PagesTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'GET /pages' do
    visit '/pages'
    assert_equal 'Docs | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_no_selector 'nav.pagination'
  end

  test 'show page' do
    id = pages(:page_1).id
    visit "/pages/#{id}"
    assert_equal 'test1 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show edit page' do
    id = pages(:page_2).id
    visit "/pages/#{id}/edit"
    assert_equal 'ページ編集 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'page has a comment form ' do
    id = pages(:page_1).id
    visit "/pages/#{id}"
    assert_selector '.thread-comment-form'
  end

  test 'title with half-width space' do
    target_page = pages(:page_1)
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
    page = pages(:page_1)
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
    within 'form[name=page]' do
      fill_in 'page[title]', with: 'tagのテスト'
      fill_in 'page[body]', with: 'tagをつけます。空白とカンマはタグには使えません。'
      tag_input = find('.ti-new-tag-input')
      tag_input.set 'tag1'
      tag_input.native.send_keys :return
      tag_input.set 'tag2'
      tag_input.native.send_keys :return
      click_on '内容を保存'
    end
    click_on 'Docs', match: :first
    assert_text 'tag1'
    assert_text 'tag2'

    click_on 'tag1', match: :first
    assert_text 'tagのテスト'
    assert_no_text 'Bootcampの作業のページ'
  end

  test 'update tags without page transitions' do
    login_user 'komagata', 'testtest'
    visit "/pages/#{pages(:page_1).id}"
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

    page_1 = pages(:page_1)
    visit "/pages/#{page_1.id}/edit"
    assert_equal 'komagata', page_1.user.login_name

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

    visit "/pages/#{pages(:page_1).id}/edit"
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
end
