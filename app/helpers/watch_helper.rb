# frozen_string_literal: true

module WatchHelper
  def filter_product(watches)
    if watches.watchable_type == 'Product'
      watches.watchable.body
    else
      watches.watchable.description
    end
  end

  def display_date(watches)
    if watches.watchable_type == 'Report'
      watches.watchable.reported_on
    elsif watches.watchable.has_attribute?(:published_at) && watches.watchable.published_at
      watches.watchable.published_at
    else
      watches.watchable.created_at
    end
  end
end
