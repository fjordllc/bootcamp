# frozen_string_literal: true

class DashboardBookmarkComponent < ViewComponent::Base
  def initialize(bookmark:)
    @bookmark = bookmark
  end

  def bookmarkable
    @bookmark.bookmarkable
  end

  def type
    bookmarkable.model_name
  end

  def author
    bookmarkable.user
  end

  def title
    type == 'Talk' ? "#{bookmarkable.user.long_name} さんの相談部屋" : bookmarkable.title
  end
end
