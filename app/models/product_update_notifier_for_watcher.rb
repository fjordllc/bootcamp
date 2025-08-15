# frozen_string_literal: true

class ProductUpdateNotifierForWatcher
  def call(_name, _started, _finished, _id, payload)
    product = payload[:product]
    current_user = payload[:current_user]
    return if product.wip? || product.watches.nil? || !current_user.nil? && current_user.admin_or_mentor?

    receiver_ids = product.watches.where.not(user_id: product.user_id).pluck(:user_id)
    receivers = User.where(id: receiver_ids)
    send_notification(
      product:,
      receivers:
    )
  end

  private

  def send_notification(product:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(product:, receiver:).notify(:product_update)
    end
  end
end
