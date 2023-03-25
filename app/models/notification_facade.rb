# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message, link)
    ActivityNotifier.with(comment:, receiver:, message:, link:).came_comment.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      comment:,
      receiver:,
      message:
    ).came_comment.deliver_later(wait: 5)
  end

  def self.product_update(product, receiver)
    ActivityNotifier.with(product:, receiver:).product_update.notify_now
    return if receiver.retired?
  end

  def self.first_report(report, receiver)
    ActivityNotifier.with(report:, receiver:).first_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report:,
      receiver:
    ).first_report.deliver_later(wait: 5)
  end

  def self.watching_notification(watchable, receiver, comment)
    ActivityNotifier.with(watchable:, receiver:, comment:).watching_notification.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      watchable:,
      receiver:,
      comment:
    ).watching_notification.deliver_later(wait: 5)
  end

  def self.trainee_report(report, receiver)
    ActivityNotifier.with(report:, receiver:).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report:,
      receiver:
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.moved_up_event_waiting_user(event, receiver)
    ActivityNotifier.with(
      event:,
      receiver:
    ).moved_up_event_waiting_user.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      event:,
      receiver:
    ).moved_up_event_waiting_user.deliver_later(wait: 5)
  end

  def self.chose_correct_answer(answer, receiver)
    ActivityNotifier.with(answer:, receiver:).chose_correct_answer.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      answer:,
      receiver:
    ).chose_correct_answer.deliver_later(wait: 5)
  end

  def self.consecutive_sad_report(report, receiver)
    ActivityNotifier.with(report:, receiver:).consecutive_sad_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report:,
      receiver:
    ).consecutive_sad_report.deliver_later(wait: 5)
  end

  def self.assigned_as_checker(product, receiver)
    ActivityNotifier.with(product:, receiver:).assigned_as_checker.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      product:,
      receiver:
    ).assigned_as_checker.deliver_later(wait: 5)
  end

  def self.hibernated(sender, receiver)
    ActivityNotifier.with(sender:, receiver:).hibernated.notify_now
    return unless receiver.mail_notification?

    NotificationMailer.with(
      sender:,
      receiver:
    ).hibernated.deliver_later(wait: 5)
  end

  def self.tomorrow_regular_event(event)
    DiscordNotifier.with(event:).tomorrow_regular_event.notify_now
  end

  def self.signed_up(sender, receiver)
    ActivityNotifier.with(sender:, receiver:, sender_roles: sender.roles_to_s).signed_up.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender:,
      receiver:
    ).signed_up.deliver_later(wait: 5)
  end

  def self.update_regular_event(regular_event, receiver)
    ActivityNotifier.with(regular_event:, receiver:).update_regular_event.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      regular_event:,
      receiver:
    ).update_regular_event.deliver_later(wait: 5)
  end

  def self.no_correct_answer(question, receiver)
    ActivityNotifier.with(question:, receiver:).no_correct_answer.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      question:,
      receiver:
    ).no_correct_answer.deliver_later(wait: 5)
  end
end
