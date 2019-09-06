# frozen_string_literal: true

class NotificationFacade
  def self.came_comment(comment, reciever, message)
    Notification.came_comment(comment, reciever, message)
    # NotificationMailer.came_comment(comment, reciever, message).deliver_now
  end

  def self.checked(check)
    Notification.checked(check)
    # NotificationMailer.checked(check).deliver_now
  end

  def self.mentioned(comment, reciever)
    Notification.mentioned(comment, reciever)
    # NotificationMailer.mentioned(comment, reciever).deliver_now
  end

  def self.submitted(subject, reciever, message)
    Notification.submitted(subject, reciever, message)
    # NotificationMailer.submitted(subject, reciever, message).deliver_now
  end

  def self.came_answer(answer)
    Notification.came_answer(answer)
    # NotificationMailer.came_answer(answer).deliver_now
  end

  def self.post_announcement(announce, reciever)
    Notification.post_announcement(announce, reciever)
    # NotificationMailer.post_announcement(announce, reciever).deliver_now
  end

  def self.came_question(question, reciever)
    Notification.came_question(question, reciever)
    # NotificationMailer.came_question(question, reciever).deliver_now
  end

  def self.first_report(report, reciever)
    Notification.first_report(report, reciever)
    # NotificationMailer.first_report(report, reciever).deliver_now
  end

  def self.watching_notification(watchable, reciever)
    Notification.watching_notification(watchable, reciever)
    # NotificationMailer.watching_notification(watchable, reciever).deliver_now
  end

  def self.retired(sender, reciever)
    Notification.retired(sender, reciever)
    NotificationMailer.retired(sender, reciever).deliver_now
  end

  def self.trainee_report(report, reciever)
    Notification.trainee_report(report, reciever)
    # NotificationMailer.trainee_report(report, reciever).deliver_now
  end
end
