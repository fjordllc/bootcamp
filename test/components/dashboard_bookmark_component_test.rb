# frozen_string_literal: true

require 'test_helper'
require 'supports/decorator_helper'

class DashboardBookmarksComponentTest < ViewComponent::TestCase
  include DecoratorHelper
  def test_renders_talk_bookmark
    bookmark = bookmarks(:bookmark31)

    render_inline(DashboardBookmarkComponent.new(bookmark:))

    assert_selector '.card-list-item__user .card-list-item__user-icon'
    assert_selector '.card-list-item-title__title', text: "#{bookmark.bookmarkable.user.long_name} さんの相談部屋"
  end

  def test_renders_non_talk_bookmark
    bookmark = decorate(bookmarks(:bookmark29))

    render_inline(DashboardBookmarkComponent.new(bookmark:))

    assert_selector '.card-list-item__label', text: bookmark.bookmarkable.class.model_name.human
    assert_selector '.card-list-item-title__title', text: bookmark.bookmarkable.title
  end
end
