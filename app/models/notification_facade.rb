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

  def self.product_update(product, receiver)
    ActivityNotifier.with(product: product, receiver: receiver).product_update.notify_now
    return if receiver.retired?
  end

  def self.trainee_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.chose_correct_answer(answer, receiver)
    ActivityNotifier.with(answer: answer, receiver: receiver).chose_correct_answer.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      answer: answer,
      receiver: receiver
    ).chose_correct_answer.deliver_later(wait: 5)
  end

  def self.tomorrow_regular_event(event)
    DiscordNotifier.with(event: event).tomorrow_regular_event.notify_now
  end

  def self.no_correct_answer(question, receiver)
    ActivityNotifier.with(question: question, receiver: receiver).no_correct_answer.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      question: question,
      receiver: receiver
    ).no_correct_answer.deliver_later(wait: 5)
  end
end
