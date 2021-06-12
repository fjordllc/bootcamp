# frozen_string_literal: true

require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  test 'prohibition of duplicate registration' do
    user = users(:machida)
    report = reports(:report1)

    Bookmark.create(user: user, bookmarkable: report)
    assert_not Bookmark.new(user: user, bookmarkable: report).valid?
  end
end
