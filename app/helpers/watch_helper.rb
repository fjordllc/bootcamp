# frozen_string_literal: true

module WatchHelper
  def filter_product(watches)
    if watches.watchable_type == 'Product'
      watches.watchable.body
    else
      watches.watchable.description
    end
  end

  def published_or_created_at(watches)
    if which_watchable_type(watches) && watches.watchable.published_at
      watches.watchable.published_at
    else
      watches.watchable.created_at
    end
  end

  def which_watchable_type(watches)
    watches.watchable_type == 'Product' || watches.watchable_type == 'Report'
  end
end
