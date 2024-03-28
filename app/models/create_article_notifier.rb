# frozen_string_literal: true

class CreateArticleNotifier
  def call(payload)
    article = payload[:article]
    return if article.wip?

    receivers = User.students_trainees_mentors_and_admins.reject { |receiver| receiver == article.user }
    send_notification(article:, receivers:)
  end

  private

  def send_notification(article:, receivers:)
    receivers.each do |receiver|
      ActivityDelivery.with(article:, receiver:).notify(:create_article)
    end
  end
end
