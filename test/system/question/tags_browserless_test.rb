# frozen_string_literal: true

require 'browserless_system_test_case'

class Question::TagsBrowserlessTest < BrowserlessSystemTestCase
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
end
