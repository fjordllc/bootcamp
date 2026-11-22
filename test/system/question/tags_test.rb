# frozen_string_literal: true

require 'application_system_test_case'

class Question::TagsTest < ApplicationSystemTestCase
  # タグ名の変更と統合の場合分けは test/integration/api/tags_test.rb で確かめる。
  # 同じ名前では変更できないことは test/system/user/tags_test.rb で確かめる。
  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    assert_non_admin_cannot_edit_tag(questions_tag_path(tag.name, all: 'true'))
  end

  test 'update tag with not existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag_text = '上級者'

    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    click_tag_name_change
    fill_in_open_tag_modal update_tag_text
    click_save_tag_name_change

    assert_text "タグ「#{update_tag_text}」のQ&A（1）"
    visit_with_auth questions_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text 'Q&Aはありません。'

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag_text), 'komagata'
    assert_text "タグ「#{update_tag_text}」のユーザー（1）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    assert_no_selector '.card-list-item'
    visit_with_auth pages_tag_path(update_tag_text), 'komagata'
    assert_selector '.card-list-item'
  end
end
