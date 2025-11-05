# frozen_string_literal: true

require 'application_system_test_case'

class Movie::TagsTest < ApplicationSystemTestCase
  test 'search movies by tag' do
    visit_with_auth movies_url, 'kimura'
    tags = find_tags('Movie')
    tags.each do |tag|
      visit_with_auth movies_tag_path(tag, all: 'true'), 'kimura'
      expected_titles = Movie.tagged_with(tag).pluck(:title)
      actual_titles = all('.thumbnail-card__title-link').map(&:text)
      assert_equal expected_titles.sort, actual_titles.sort
    end
  end

  test 'update tags without page transitions' do
    visit_with_auth movie_path(movies(:movie2)), 'komagata'
    find('.tag-links__item-edit').click
    fill_in_tag '追加タグ'
    click_on '保存'
    assert_text '追加タグ'
  end

  test 'admin can edit tag' do
    tag = acts_as_taggable_on_tags('cat')
    visit_with_auth movies_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('タグ名変更')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('cat')
    visit_with_auth movies_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('タグ名変更')
  end

  test 'admin updates a tag to a new name' do
    old_tag = acts_as_taggable_on_tags('beginner')
    new_tag_name = '上級者'

    visit_with_auth movies_tag_path(old_tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: new_tag_name)
    click_button '変更'

    assert_text "タグ「#{new_tag_name}」の動画（1）"
  end

  test 'admin merges a tag into an existing tag' do
    existing_tag = acts_as_taggable_on_tags('game')
    new_tag = acts_as_taggable_on_tags('beginner')

    visit_with_auth movies_tag_path(existing_tag.name, all: 'true'), 'komagata'

    click_button 'タグ名変更'
    fill_in 'tag[name]', with: new_tag.name
    click_button '変更'

    assert_text "タグ「#{new_tag.name}」の動画（2）"
  end

  test 'update tag with same value' do
    tag = acts_as_taggable_on_tags('cat')

    visit_with_auth movies_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: tag.name)
    assert_selector('button.is-primary[disabled]', text: '変更')
  end
end
