# frozen_string_literal: true

class ProductUpdateNotifierForChecker
  def call(_name, _started, _finished, _id, payload)
    product = payload[:product]
    current_user = payload[:current_user]
    return if product.wip? || product.checker_id.nil? || !current_user.nil? && current_user.admin_or_mentor?

    ActivityDelivery.with(
      product:,
      receiver: product.checker
    ).notify(:product_update)
  end
end
