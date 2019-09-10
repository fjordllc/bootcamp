# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, receiver, message)
    Notification.came_comment(comment, receiver, message)
    NotificationMailer.came_comment(comment, receiver, message).deliver_now
  end

  def self.checked(check)
    Notification.checked(check)
    NotificationMailer.checked(check).deliver_now
  end

  def self.mentioned(comment, receiver)
    Notification.mentioned(comment, receiver)
    NotificationMailer.mentioned(comment, receiver).deliver_now
  end

  def self.submitted(subject, receiver, message)
    Notification.submitted(subject, receiver, message)
    # NotificationMailer.submitted(subject, receiver, message).deliver_now
  end

  def self.came_answer(answer)
    Notification.came_answer(answer)
    NotificationMailer.came_answer(answer).deliver_now
  end

  def self.post_announcement(announce, receiver)
    Notification.post_announcement(announce, receiver)
    NotificationMailer.post_announcement(announce, receiver).deliver_now
  end

  def self.came_question(question, receiver)
    Notification.came_question(question, receiver)
    NotificationMailer.came_question(question, receiver).deliver_now
  end

  def self.first_report(report, receiver)
    Notification.first_report(report, receiver)
    NotificationMailer.first_report(report, receiver).deliver_now
  end

  def self.watching_notification(watchable, receiver)
    Notification.watching_notification(watchable, receiver)
    NotificationMailer.watching_notification(watchable, receiver).deliver_now
  end

  def self.retired(sender, receiver)
    Notification.retired(sender, receiver)
    NotificationMailer.retired(sender, receiver).deliver_now
  end

  def self.trainee_report(report, receiver)
    Notification.trainee_report(report, receiver)
    NotificationMailer.trainee_report(report, receiver).deliver_now
  end
end
