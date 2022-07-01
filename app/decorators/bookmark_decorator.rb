# frozen_string_literal: true

module BookmarkDecorator
  def display_date
    bookmarkable_type == 'Report' ? bookmarkable.reported_on : bookmarkable.created_at
  end
end
