# frozen_string_literal: true

class DashboardBookmarksComponent < ViewComponent::Base
  def initialize(bookmarks:)
    @bookmarks = bookmarks
  end
end
