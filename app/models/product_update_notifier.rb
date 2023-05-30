# frozen_string_literal: true

class ProductUpdateNotifier
  def call(product)
    return if product.wip? || product.checker_id.blank?

    def call(payload)
      product = payload[:product]
      current_user = payload[:current_user]

      NotificationFacade.product_update(product, current_user)
    end
  end
end
