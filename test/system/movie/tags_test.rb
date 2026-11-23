# frozen_string_literal: true

require 'application_system_test_case'

class Movie::TagsTest < ApplicationSystemTestCase
  # タグ名の変更と統合の場合分けは test/integration/api/tags_test.rb で確かめる。
  # 同じ名前では変更できないことは test/system/user/tags_test.rb で確かめる。
  test 'update tags without page transitions' do
    visit_with_auth movie_path(movies(:movie2)), 'komagata'
    click_tag_edit
    fill_in_tag '追加タグ'
    click_save_tags
    assert_text '追加タグ'
  end

  test 'admin updates a tag to a new name' do
    old_tag = acts_as_taggable_on_tags('beginner')
    new_tag_name = '上級者'

    visit_with_auth movies_tag_path(old_tag.name, all: 'true'), 'komagata'
    click_tag_name_change
    fill_in_open_tag_modal new_tag_name
    click_save_tag_name_change

    assert_text "タグ「#{new_tag_name}」の動画（1）"
  end
end
