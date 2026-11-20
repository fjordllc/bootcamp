# frozen_string_literal: true

require 'browserless_system_test_case'

class Page::TagsBrowserlessTest < BrowserlessSystemTestCase
  test 'search pages by tag' do
    visit_with_auth new_page_path, 'kimura'
    tags = find_tags('Page')
    tags.each do |tag|
      visit_with_auth pages_tag_path(tag, all: 'true'), 'kimura'
      assert_equal Page.tagged_with(tag).pluck(:title),
                   all('.card-list-item-title__link').map(&:text)
    end
  end
end
