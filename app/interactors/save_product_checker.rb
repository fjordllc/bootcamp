# frozen_string_literal: true

class SaveProductChecker
  include Interactor

  def call
    context.fail! if context.product.assignment.other_checker_exists?(context.user_id)
    context.product.checker_id = context.user_id
    Cache.delete_self_assigned_no_replied_product_count(context.user_id)
    context.product.save!
  end
end
