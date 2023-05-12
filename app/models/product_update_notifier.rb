# frozen_string_literal: true

class ProductUpdateNotifier
  def call(product)
    return if product.wip? || product.checker_id.blank?

    NotificationFacade.product_update(product, User.find(product.checker_id))
  end
end
