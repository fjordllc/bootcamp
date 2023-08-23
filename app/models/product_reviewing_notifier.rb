# frozen_string_literal: true

class ProductReviewingNotifier
  def call(product)
    return if product.checker_id.nil?

    ActivityDelivery.with(product:, receiver: User.find(product.user.id)).notify(:product_reviewing)
  end
end
