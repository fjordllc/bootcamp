# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message)
    Notification.came_comment(comment, receiver, message)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        comment: comment,
        receiver: receiver,
        message: message
      ).came_comment.deliver_later
    end
  end

  def self.checked(check)
    Notification.checked(check)
    receiver = check.receiver
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(check: check).checked.deliver_later
    end
  end

  def self.mentioned(comment, receiver)
    Notification.mentioned(comment, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        comment: comment,
        receiver: receiver
      ).mentioned.deliver_later
    end
  end

  def self.submitted(subject, receiver, message)
    Notification.submitted(subject, receiver, message)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        product: subject,
        receiver: receiver,
        message: message
      ).submitted.deliver_later
    end
  end

  def self.came_answer(answer)
    Notification.came_answer(answer)
    receiver = answer.receiver
    if answer.receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(answer: answer).came_answer.deliver_later
    end
  end

  def self.post_announcement(announce, receiver)
    Notification.post_announcement(announce, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        announcement: announce,
        receiver: receiver
      ).post_announcement.deliver_later
    end
  end

  def self.came_question(question, receiver)
    Notification.came_question(question, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        question: question,
        receiver: receiver
      ).came_question.deliver_later
    end
  end

  def self.first_report(report, receiver)
    Notification.first_report(report, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        report: report,
        receiver: receiver
      ).first_report.deliver_later
    end
  end

  def self.watching_notification(watchable, receiver, comment)
    Notification.watching_notification(watchable, receiver, comment)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        watchable: watchable,
        receiver: receiver,
        comment: comment
      ).watching_notification.deliver_later
    end
  end

  def self.retired(sender, receiver)
    Notification.retired(sender, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        sender: sender,
        receiver: receiver
      ).retired.deliver_later
    end
  end

  def self.trainee_report(report, receiver)
    Notification.trainee_report(report, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        report: report,
        receiver: receiver
      ).trainee_report.deliver_later
    end
  end

  def self.moved_up_event_waiting_user(event, receiver)
    Notification.moved_up_event_waiting_user(event, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.with(
        event: event,
        receiver: receiver
      ).moved_up_event_waiting_user.deliver_later
    end
  end
end
