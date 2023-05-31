# frozen_string_literal: true

class ProductUpdateNotifier
  def call(payload)
    product = payload[:product]
    current_user = payload[:current_user]
    return if product.wip? || product.checker_id.nil? || !current_user.nil? && current_user.admin_or_mentor?

    NotificationFacade.product_update(product, User.find(product.checker_id))
  end
end
