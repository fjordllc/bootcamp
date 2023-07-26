# frozen_string_literal: true

class ProductReviewingNotifier
  def call(product)
    return if product.checker_id.nil?

    NotificationFacade.product_reviewing(product, product.user)
  end
end
