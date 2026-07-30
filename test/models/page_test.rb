# frozen_string_literal: true

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test '.for_practice_including_source returns practice and source pages' do
    practice_page = pages(:page12)
    source_page = pages(:page13)
    other_page = pages(:page11)
    result = Page.for_practice_including_source(practice_page.practice)

    assert_includes result, practice_page
    assert_includes result, source_page
    assert_not_includes result, other_page
  end
end
