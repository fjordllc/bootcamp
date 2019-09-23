# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message)
    Notification.came_comment(comment, receiver, message)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.came_comment(comment, receiver, message).deliver_now
    end
  end

  def self.checked(check)
    Notification.checked(check)
    receiver = check.receiver
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.checked(check).deliver_now
    end
  end

  def self.mentioned(comment, receiver)
    Notification.mentioned(comment, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.mentioned(comment, receiver).deliver_now
    end
  end

  def self.submitted(subject, receiver, message)
    Notification.submitted(subject, receiver, message)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.submitted(subject, receiver, message).deliver_now
    end
  end

  def self.came_answer(answer)
    Notification.came_answer(answer)
    receiver = answer.receiver
    if answer.receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.came_answer(answer).deliver_now
    end
  end

  def self.post_announcement(announce, receiver)
    Notification.post_announcement(announce, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.post_announcement(announce, receiver).deliver_now
    end
  end

  def self.came_question(question, receiver)
    Notification.came_question(question, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.came_question(question, receiver).deliver_now
    end
  end

  def self.first_report(report, receiver)
    Notification.first_report(report, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.first_report(report, receiver).deliver_now
    end
  end

  def self.watching_notification(watchable, receiver)
    Notification.watching_notification(watchable, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.watching_notification(watchable, receiver).deliver_now
    end
  end

  def self.retired(sender, receiver)
    Notification.retired(sender, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.retired(sender, receiver).deliver_now
    end
  end

  def self.trainee_report(report, receiver)
    Notification.trainee_report(report, receiver)
    if receiver.mail_notification? && !receiver.retired_on?
      NotificationMailer.trainee_report(report, receiver).deliver_now
    end
  end
end
