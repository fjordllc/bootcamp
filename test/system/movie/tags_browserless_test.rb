# frozen_string_literal: true

require 'browserless_system_test_case'

class Movie::TagsBrowserlessTest < BrowserlessSystemTestCase
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
end
