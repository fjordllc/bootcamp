# frozen_string_literal: true

require 'application_system_test_case'

class Page::TagsTest < ApplicationSystemTestCase
  test 'search pages by tag' do
    visit_with_auth new_page_url, 'kimura'
    tags = find_tags('Page')
    tags.each do |tag|
      visit_with_auth pages_tag_path(tag, all: 'true'), 'kimura'
      assert_equal Page.tagged_with(tag).pluck(:title),
                   all('.card-list-item-title__link').map(&:text)
    end
  end

  test 'update tags without page transitions' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    find('.tag-links__item-edit').click
    fill_in_tag '追加タグ'
    click_on '保存'
    assert_equal Page.tagged_with('追加タグ').pluck(:title),
                 all('.card-list-item-title__link').map(&:text)
  end

  test 'admin can edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('タグ名変更')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('タグ名変更')
  end

  test 'update tag with not existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag_text = '上級者'

    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag_text)
    click_button '変更'
    assert_text 'タグ 「上級者」'

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text 'Q&Aはありません。'
    visit_with_auth questions_tag_path(update_tag_text, all: 'true'), 'komagata'
    assert_text "タグ「#{update_tag_text}」のQ&A（1）"

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag_text), 'komagata'
    assert_text "タグ「#{update_tag_text}」のユーザー（1）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_selector?('card-list-item')
    visit_with_auth pages_tag_path(update_tag_text), 'komagata'
    has_selector?('card-list-item')
  end

  test 'update tag with existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag = acts_as_taggable_on_tags('intermediate')

    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag.name)
    click_button '変更'
    assert_text 'タグ 「中級者」'

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text 'Q&Aはありません。'
    visit_with_auth questions_tag_path(update_tag.name, all: 'true'), 'komagata'
    assert_text "タグ「#{update_tag.name}」のQ&A（2）"

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag.name), 'komagata'
    assert_text "タグ「#{update_tag.name}」のユーザー（2）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('card-list-item')
    visit_with_auth pages_tag_path(update_tag.name), 'komagata'
    has_selector?('card-list-item')
  end

  test 'update tag with same value' do
    tag = acts_as_taggable_on_tags('beginner')

    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: tag.name)
    has_field?('変更', disabled: true)
  end

  test 'alert when enter tag with space on creation page' do
    visit_with_auth new_page_path, 'kimura'
    ['半角スペースは 使えない', '全角スペースも　使えない'].each do |tag|
      fill_in_tag_with_alert tag
      assert_no_selector('.tagify__tag')
    end
    fill_in_tag 'foo'
    assert_selector('input[name="page[tag_list]"][value="foo"]', visible: false)
    within('form[name=page]') do
      fill_in('page[title]', with: 'test title')
      fill_in('page[body]', with: 'test body')
      click_button 'Docを公開'
    end
    assert_selector('.tag-links__item-link', text: 'foo', count: 1)
  end

  test 'alert when enter one dot only tag on creation page' do
    visit_with_auth new_page_path, 'kimura'
    fill_in_tag_with_alert '.'
    fill_in_tag 'foo'
    within('form[name=page]') do
      fill_in('page[title]', with: 'test title')
      fill_in('page[body]', with: 'test body')
      click_button 'Docを公開'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text).sort
  end

  test 'alert when enter tag with space on update page' do
    visit_with_auth "/pages/#{pages(:page3).id}/edit", 'kimura'
    ['半角スペースは 使えない', '全角スペースも　使えない'].each do |tag|
      fill_in_tag_with_alert tag
    end
    fill_in_tag 'foo'
    within('form[name=page]') do
      fill_in('page[title]', with: 'test title')
      fill_in('page[body]', with: 'test body')
      click_button '内容を更新'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text).sort
  end

  test 'alert when enter one dot only tag on update page' do
    visit_with_auth "/pages/#{pages(:page3).id}/edit", 'kimura'
    fill_in_tag_with_alert '.'
    fill_in_tag 'foo'
    within('form[name=page]') do
      fill_in('page[title]', with: 'test title')
      fill_in('page[body]', with: 'test body')
      click_button '内容を更新'
    end
    assert_equal ['foo'], all('.tag-links__item-link').map(&:text)
  end
end
