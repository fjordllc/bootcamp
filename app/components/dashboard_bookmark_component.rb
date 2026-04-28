# frozen_string_literal: true

class DashboardBookmarkComponent < ViewComponent::Base
  def initialize(bookmark:)
    @bookmark = bookmark
  end

  delegate :bookmarkable, to: :@bookmark

  def type
    bookmarkable.model_name
  end

  def author
    bookmarkable.user
  end

  def title
    type == 'Talk' ? "#{bookmarkable.user.long_name} さんの相談部屋" : bookmarkable.title
  end

  def reported_on_or_created_at
    @bookmark.bookmarkable_type == 'Report' ? bookmarkable.reported_on.to_time : bookmarkable.created_at
  end

  private

  attr_reader :bookmark
end
