# frozen_string_literal: true

class ProductNotifierForColleague
  def call(_name, _started, _finished, _unique_id, payload)
    product = payload[:product]
    return if product.wip

    notify_advisers product if product.user.trainee? && product.user.company
  end

  private

  def notify_advisers(product)
    send_notification(
      product:,
      receivers: product.user.company.advisers
    )
  end

  def send_notification(product:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(product:, receiver:).notify(product.notification_type)
    end
  end
end
