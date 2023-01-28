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

  def self.came_question(question, receiver)
    ActivityNotifier.with(question: question, receiver: receiver).came_question.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      question: question,
      receiver: receiver
    ).came_question.deliver_later(wait: 5)
  end

  def self.first_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).first_report.notify_now
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

  def self.trainee_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.following_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).following_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).following_report.deliver_later(wait: 5)
  end

  def self.moved_up_event_waiting_user(event, receiver)
    ActivityNotifier.with(
      event: event,
      receiver: receiver
    ).moved_up_event_waiting_user.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      event: event,
      receiver: receiver
    ).moved_up_event_waiting_user.deliver_later(wait: 5)
  end

  def self.create_page(page, receiver)
    ActivityNotifier.with(page: page, receiver: receiver).create_page.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      page: page,
      receiver: receiver
    ).create_page.deliver_later(wait: 5)
  end

  def self.chose_correct_answer(answer, receiver)
    Notification.chose_correct_answer(answer, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      answer: answer,
      receiver: receiver
    ).chose_correct_answer.deliver_later(wait: 5)
  end

  def self.consecutive_sad_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).consecutive_sad_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).consecutive_sad_report.deliver_later(wait: 5)
  end

  def self.assigned_as_checker(product, receiver)
    ActivityNotifier.with(product: product, receiver: receiver).assigned_as_checker.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      product: product,
      receiver: receiver
    ).assigned_as_checker.deliver_later(wait: 5)
  end

  def self.hibernated(sender, receiver)
    ActivityNotifier.with(sender: sender, receiver: receiver).hibernated.notify_now
    return unless receiver.mail_notification?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).hibernated.deliver_later(wait: 5)
  end

  def self.tomorrow_regular_event(event)
    DiscordNotifier.with(event: event).tomorrow_regular_event.notify_now
  end

  def self.signed_up(sender, receiver)
    ActivityNotifier.with(sender: sender, receiver: receiver, sender_roles: sender.roles_to_s).signed_up.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).signed_up.deliver_later(wait: 5)
  end

  def self.update_regular_event(regular_event, receiver)
    ActivityNotifier.with(regular_event: regular_event, receiver: receiver).update_regular_event.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      regular_event: regular_event,
      receiver: receiver
    ).update_regular_event.deliver_later(wait: 5)
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
