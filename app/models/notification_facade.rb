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

  def self.checked(check)
    ActivityNotifier.with(check: check, receiver: check.receiver).checked.notify_now
    receiver = check.receiver
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(check: check).checked.deliver_later(wait: 5)
  end

  def self.product_update(product, receiver)
    ActivityNotifier.with(product: product, receiver: receiver).product_update.notify_now
    return if receiver.retired?
  end

  def self.mentioned(mentionable, receiver)
    ActivityNotifier.with(mentionable: mentionable, receiver: receiver).mentioned.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      mentionable: mentionable,
      receiver: receiver
    ).mentioned.deliver_later(wait: 5)
  end

  def self.submitted(subject, receiver, message)
    ActivityNotifier.with(subject: subject, receiver: receiver, message: message).submitted.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      product: subject,
      receiver: receiver,
      message: message
    ).submitted.deliver_later(wait: 5)
  end

  def self.came_answer(answer)
    receiver = answer.receiver
    ActivityNotifier.with(answer: answer).came_answer.notify_now
    return unless answer.receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(answer: answer).came_answer.deliver_later(wait: 5)
  end

  def self.post_announcement(announce, receiver)
    ActivityNotifier.with(announce: announce, receiver: receiver).post_announcement.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      announcement: announce,
      receiver: receiver
    ).post_announcement.deliver_later(wait: 5)
  end

  def self.came_question(question, receiver)
    ActivityNotifier.with(question: question, receiver: receiver).came_question.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      question: question,
      receiver: receiver
    ).came_question.deliver_later(wait: 5)
  end

  def self.first_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).first_report.notify_now if receiver.current_student? || receiver.admin_or_mentor?
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).first_report.deliver_later(wait: 5)
  end

  def self.watching_notification(watchable, receiver, comment)
    ActivityNotifier.with(watchable: watchable, receiver: receiver, comment: comment).watching_notification.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      watchable: watchable,
      receiver: receiver,
      comment: comment
    ).watching_notification.deliver_later(wait: 5)
  end

  def self.retired(sender, receiver)
    ActivityNotifier.with(sender: sender, receiver: receiver).retired.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).retired.deliver_later(wait: 5)
  end

  def self.three_months_after_retirement(sender, receiver)
    ActivityNotifier.with(sender: sender, receiver: receiver).three_months_after_retirement.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).three_months_after_retirement.deliver_later(wait: 5)
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
end
