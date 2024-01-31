# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class BookmarkDecoratorTest < ActiveDecoratorTestCase
  test '#reported_on_or_created_at' do
    bookmark31 = decorate(bookmarks(:bookmark31))
    bookmark27 = decorate(bookmarks(:bookmark27))
    assert_equal bookmark31.bookmarkable.created_at, bookmark31.reported_on_or_created_at
    assert_equal bookmark27.bookmarkable.reported_on, bookmark27.reported_on_or_created_at
  end
end
