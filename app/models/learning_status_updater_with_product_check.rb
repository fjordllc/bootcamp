# frozen_string_literal: true

class LearningStatusUpdaterWithProductCheck
  def call(check)
    return unless check.checkable_type == 'Product'

    check.checkable.change_learning_status(:complete)
  end
end
