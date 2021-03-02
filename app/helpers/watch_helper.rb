# frozen_string_literal: true

module WatchHelper
  def filter_product(watches)
    if watches.watchable_type == 'Product'
      watches.watchable.body
    else
      watches.watchable.description
    end
  end
end
