# frozen_string_literal: true

class ArticleNotifier
  def call(payload)
    article = payload[:article]
    return unless article.saved_change_to_attribute?(:published_at, from: nil)

    receivers = User.notification_receiver(article.target).reject { |receiver| receiver == article.sender }
    send_notification(article:, receivers:)
  end

  private

  def send_notification(article:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(article:, receiver:).notify(:create_article)
    end
  end
end
