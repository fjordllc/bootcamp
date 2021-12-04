# frozen_string_literal: true

require 'application_system_test_case'

class Question::TagsTest < ApplicationSystemTestCase
  test 'search pages by tag' do
    visit_with_auth pages_url, 'kimura'
    click_on 'Doc作成'
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
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    find('.tag-links__item-edit').click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '追加タグ'
    tag_input.native.send_keys :return
    click_on '保存'
    wait_for_vuejs
    assert_text '追加タグ'
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
    wait_for_vuejs

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text '質問はありません。'
    visit_with_auth questions_tag_path(update_tag_text, all: 'true'), 'komagata'
    assert_text "タグ「#{update_tag_text}」のQ&A（1）"

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag_text), 'komagata'
    assert_text "タグ「#{update_tag_text}」のユーザー（1）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('thread-list-item')
    visit_with_auth pages_tag_path(update_tag_text), 'komagata'
    has_selector?('thread-list-item')
  end

  test 'update tag with existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag = acts_as_taggable_on_tags('intermediate')

    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag.name)
    click_button '変更'
    wait_for_vuejs

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text '質問はありません。'
    visit_with_auth questions_tag_path(update_tag.name, all: 'true'), 'komagata'
    assert_text "タグ「#{update_tag.name}」のQ&A（2）"

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag.name), 'komagata'
    assert_text "タグ「#{update_tag.name}」のユーザー（2）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('thread-list-item')
    visit_with_auth pages_tag_path(update_tag.name), 'komagata'
    has_selector?('thread-list-item')
  end

  test 'update tag with same value' do
    tag = acts_as_taggable_on_tags('beginner')

    visit_with_auth pages_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: tag.name)
    has_field?('変更', disabled: true)
  end
end
