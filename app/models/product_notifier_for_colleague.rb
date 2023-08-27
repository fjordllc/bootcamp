# frozen_string_literal: true

class ProductNotifierForColleague
  def call(payload)
    product =
      case payload
      when Hash
        payload[:product]
      else
        payload
      end
    return if product.wip

    notify_advisers product if product.user.trainee? && product.user.company
  end

  private

  def notify_advisers(product)
    send_notification(
      product: product,
      receivers: product.user.company.advisers
    )
  end

  def send_notification(product:, receivers:)
    notification = product.updated_after_submission? ? :product_update : :submitted
    receivers.each do |receiver|
      ActivityDelivery.with(product: product, receiver: receiver).notify(notification)
    end
  end
end
