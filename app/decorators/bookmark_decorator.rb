# frozen_string_literal: true

module BookmarkDecorator
  def reported_on_or_created_at
    bookmarkable_type == 'Report' ? bookmarkable.reported_on : bookmarkable.created_at
  end
end
