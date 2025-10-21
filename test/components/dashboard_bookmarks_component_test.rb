# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class DashboardBookmarkComponentTest < ViewComponent::TestCase
  include DecoratorHelper

  def test_renders_all_bookmarks_when_present
    bookmarks = [decorate(bookmarks(:bookmark28)), decorate(bookmarks(:bookmark29))]

    render_inline(DashboardBookmarksComponent.new(bookmarks:))

    assert_selector '.card-list-item', count: bookmarks.count
  end
end
