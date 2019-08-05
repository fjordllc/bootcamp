# frozen_string_literal: true

<<<<<<< HEAD
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: "User"

  paginates_per 20

  enum kind: {
    came_comment:  0,
    checked:       1,
    mentioned:     2,
    submitted:     3,
    answered:      4,
    announced:     5,
    came_question: 6,
    report_submitted:  7,
    watching:      8,
    retired:       9
  }

  scope :unreads, -> {
    into_one = select(:path).group(:path).maximum(:created_at)
    where(read: false, created_at: into_one.values).order(created_at: :desc)
  }
  scope :with_avatar, -> { preload(sender: { avatar_attachment: :blob }) }

=======
class Notification
>>>>>>> 通知をメールでも飛ぶように変更
  def self.came_comment(comment, reciever, message)
    InnerNotification.came_comment(comment, reciever, message)
    NotificationMailer.came_comment(comment, reciever, message).deliver_now
  end

  def self.checked(check)
    InnerNotification.checked(check)
    NotificationMailer.checked(check).deliver_now
  end

  def self.mentioned(comment, reciever)
    InnerNotification.mentioned(comment, reciever)
    NotificationMailer.mentioned(comment, reciever).deliver_now
  end

  def self.submitted(subject, reciever, message)
    InnerNotification.submitted(subject, reciever, message)
    NotificationMailer.submitted(subject, reciever, message).deliver_now
  end

  def self.came_answer(answer)
    InnerNotification.came_answer(answer)
    NotificationMailer.came_answer(answer).deliver_now
  end

  def self.post_announcement(announce, reciever)
    InnerNotification.post_announcement(announce, reciever)
    NotificationMailer.post_announcement(announce, reciever).deliver_now
  end

  def self.came_question(question, reciever)
    InnerNotification.came_question(question, reciever)
    NotificationMailer.came_question(question, reciever).deliver_now
  end

  def self.first_report(report, reciever)
    InnerNotification.first_report(report, reciever)
    NotificationMailer.first_report(report, reciever).deliver_now
  end

  def self.watching_notification(watchable, reciever)
    InnerNotification.watching_notification(watchable, reciever)
    NotificationMailer.watching_notification(watchable, reciever).deliver_now
  end

  def self.retired(sender, reciever)
    InnerNotification.retired(sender, reciever)
    NotificationMailer.retired(sender, reciever).deliver_now
  end
end
