# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message)
    Notification.came_comment(comment, receiver, message)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      comment: comment,
      receiver: receiver,
      message: message
    ).came_comment.deliver_later(wait: 5)
  end

  def self.checked(check)
    Notification.checked(check)
    receiver = check.receiver
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(check: check).checked.deliver_later(wait: 5)
  end

  def self.product_update(product, receiver)
    Notification.product_update(product, receiver)
    return if receiver.retired?
  end

  def self.mentioned(mentionable, receiver)
    Notification.mentioned(mentionable, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      mentionable: mentionable,
      receiver: receiver
    ).mentioned.deliver_later(wait: 5)
  end

  def self.submitted(subject, receiver, message)
    Notification.submitted(subject, receiver, message)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      product: subject,
      receiver: receiver,
      message: message
    ).submitted.deliver_later(wait: 5)
  end

  def self.came_answer(answer)
    Notification.came_answer(answer)
    receiver = answer.receiver
    return unless answer.receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(answer: answer).came_answer.deliver_later(wait: 5)
  end

  def self.post_announcement(announce, receiver)
    Notification.post_announcement(announce, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      announcement: announce,
      receiver: receiver
    ).post_announcement.deliver_later(wait: 5)
  end

  def self.came_question(question, receiver)
    Notification.came_question(question, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      question: question,
      receiver: receiver
    ).came_question.deliver_later(wait: 5)
  end

  def self.first_report(report, receiver)
    Notification.first_report(report, receiver) if receiver.student_or_trainee? || receiver.admin_or_mentor?
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).first_report.deliver_later(wait: 5)
  end

  def self.watching_notification(watchable, receiver, comment)
    Notification.watching_notification(watchable, receiver, comment)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      watchable: watchable,
      receiver: receiver,
      comment: comment
    ).watching_notification.deliver_later(wait: 5)
  end

  def self.retired(sender, receiver)
    Notification.retired(sender, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).retired.deliver_later(wait: 5)
  end

  def self.three_months_after_retirement(sender, receiver)
    Notification.three_months_after_retirement(sender, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      sender: sender,
      receiver: receiver
    ).three_months_after_retirement.deliver_later(wait: 5)
  end

  def self.trainee_report(report, receiver)
    Notification.trainee_report(report, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.following_report(report, receiver)
    Notification.following_report(report, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).following_report.deliver_later(wait: 5)
  end

  def self.moved_up_event_waiting_user(event, receiver)
    Notification.moved_up_event_waiting_user(event, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      event: event,
      receiver: receiver
    ).moved_up_event_waiting_user.deliver_later(wait: 5)
  end

  def self.create_page(page, receiver)
    Notification.create_page(page, receiver)
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
    Notification.consecutive_sad_report(report, receiver)
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).consecutive_sad_report.deliver_later(wait: 5)
  end

  def self.assigned_as_checker(product, receiver)
    Notification.assigned_as_checker(product, receiver)
    return unless receiver.mail_notification? && !receiver.retired_on?

    NotificationMailer.with(
      product: product,
      receiver: receiver
    ).assigned_as_checker.deliver_later(wait: 5)
  end
end
