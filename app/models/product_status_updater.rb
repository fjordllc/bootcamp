# frozen_string_literal: true

class ProductStatusUpdater
  def call(check)
    return unless check.checkable_type == 'Product'

    check.checkable.change_learning_status(:complete)
  end
end
