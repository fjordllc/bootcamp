# frozen_string_literal: true

class ProductNotifier
  def call(product)
    return if product.wip

    notify_advisers product if product.user.trainee? && product.user.company
  end

  private

  def notify_advisers(product)
    send_notification(
      product: product,
      receivers: product.user.company.advisers,
      message: "#{product.user.login_name}さんが#{product.title}を提出しました。"
    )
  end

  def send_notification(product:, receivers:, message:)
    receivers.each do |receiver|
      NotificationFacade.submitted(product, receiver, message)
    end
  end
end
