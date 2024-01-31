# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class BookmarkDecoratorTest < ActiveDecoratorTestCase
  test '#reported_on_or_created_at' do
    assert_equal bookmarks(:bookmark31).bookmarkable.created_at, decorate(bookmark31).reported_on_or_created_at
    assert_equal bookmarks(:bookmark27).bookmarkable.reported_on, decorate(bookmark27).reported_on_or_created_at
  end
end
