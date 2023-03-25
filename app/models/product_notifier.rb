# frozen_string_literal: true

class ProductNotifier
  def call(product)
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
      ActivityDelivery.with(product:, receiver:).notify(:submitted)
    end
  end
end
