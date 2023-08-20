# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message, link)
    ActivityNotifier.with(comment: comment, receiver: receiver, message: message, link: link).came_comment.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      comment: comment,
      receiver: receiver,
      message: message
    ).came_comment.deliver_later(wait: 5)
  end

  def self.trainee_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.coming_soon_regular_events(today_events, tomorrow_events)
    DiscordNotifier.with(today_events: today_events, tomorrow_events: tomorrow_events).coming_soon_regular_events.notify_now
  end

  def self.product_reviewing(product, receiver)
    ActivityNotifier.with(product: product, receiver: receiver).product_reviewing.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      product: product,
      receiver: receiver
    ).product_reviewing.deliver_now
  end
end
