# frozen_string_literal: true

require 'application_system_test_case'

class Question::TagsTest < ApplicationSystemTestCase
  test 'search questions by tag' do
    visit_with_auth questions_url, 'kimura'
    click_on '質問する'
    tag_list = ['tag1',
                'ドットつき.タグ',
                'ドットが.2つ以上の.タグ',
                '.先頭がドット',
                '最後がドット.']
    within 'form[name=question]' do
      fill_in 'question[title]', with: 'tagテストの質問'
      fill_in 'question[description]', with: 'tagテストの質問です。'
      tag_input = find('.ti-new-tag-input')
      tag_list.each do |tag|
        tag_input.set tag
        tag_input.native.send_keys :return
      end
      click_button '登録する'
    end
    click_on 'Q&A', match: :first

    tag_list.each do |tag|
      assert_text tag
      click_on tag, match: :first
      assert_text 'tagテストの質問'
      assert_no_text 'どのエディターを使うのが良いでしょうか'
    end
  end

  test 'update tags without page transitions' do
    visit_with_auth question_path(questions(:question2)), 'komagata'
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
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('このタグを編集する')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('このタグを編集する')
  end

  test 'update tag with not existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag_text = '上級者'

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'このタグを編集する'
    fill_in('tag[name]', with: update_tag_text)
    click_button '更新'
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

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'このタグを編集する'
    fill_in('tag[name]', with: update_tag.name)
    click_button '更新'
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

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'このタグを編集する'
    fill_in('tag[name]', with: tag.name)
    has_field?('更新', disabled: true)
  end
end
