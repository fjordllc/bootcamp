# frozen_string_literal: true

class ProductNotifierForPracticeWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    product = payload[:product]
    return if product.wip

    practice = Practice.find(product.practice_id)
    mentor_ids = practice.watches.where.not(user_id: product.user_id).pluck(:user_id)
    mentors = User.where(id: mentor_ids)
    send_notification(
      product:,
      receivers: mentors
    )
  end

  private

  def send_notification(product:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(product:, receiver:).notify(product.notification_type)
    end
  end
end
