# frozen_string_literal: true

require 'application_system_test_case'

class Question::TagsTest < ApplicationSystemTestCase
  test 'search questions by tag' do
    visit_with_auth questions_url, 'kimura'
    tags = find_tags('Question')
    tags.each do |tag|
      visit_with_auth questions_tag_path(tag, all: 'true'), 'kimura'
      titles = Question.tagged_with(tag).pluck(:title)
      texts = all('.card-list-item-title__link').map(&:text)
      assert_equal titles, texts
    end
  end

  test 'update tags without page transitions' do
    visit_with_auth question_path(questions(:question2)), 'komagata'
    find('.tag-links__item-edit').click
    fill_in_tag '追加タグ'
    click_on '保存'
    assert_text '追加タグ'
  end

  test 'admin can edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('タグ名変更')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('タグ名変更')
  end

  test 'update tag with not existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag_text = '上級者'

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag_text)
    click_button '変更'

    assert_text "タグ「#{update_tag_text}」のQ&A（1）"
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text 'Q&Aはありません。'

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag_text), 'komagata'
    assert_text "タグ「#{update_tag_text}」のユーザー（1）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('card-list-item')
    visit_with_auth pages_tag_path(update_tag_text), 'komagata'
    has_selector?('card-list-item')
  end

  test 'update tag with existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag = acts_as_taggable_on_tags('intermediate')

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag.name)
    click_button '変更'

    assert_text "タグ「#{update_tag.name}」のQ&A（2）"
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text 'Q&Aはありません。'

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

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: tag.name)
    has_field?('変更', disabled: true)
  end
end
