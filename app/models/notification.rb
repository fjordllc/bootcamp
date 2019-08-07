# frozen_string_literal: true

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
  scope :unreads_with_avatar, -> { unreads.with_avatar.limit(99) }

  def self.came_comment(comment, reciever, message)
    Notification.create!(
      kind:    0,
      user:    reciever,
      sender:  comment.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      message: message,
      read:    false
    )
  end

  def self.checked(check)
    Notification.create!(
      kind:    1,
      user:    check.reciever,
      sender:  check.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
      message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      read:    false
    )
  end

  def self.mentioned(comment, reciever)
    Notification.create!(
      kind:    2,
      user:    reciever,
      sender:  comment.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      message: "#{comment.sender.login_name}さんからメンションがきました。",
      read:    false
    )
  end

  def self.submitted(subject, reciever, message)
    Notification.create!(
      kind:    3,
      user:    reciever,
      sender:  subject.user,
      path:    Rails.application.routes.url_helpers.polymorphic_path(subject),
      message: message,
      read:    false
    )
  end

  def self.came_answer(answer)
    Notification.create!(
      kind:    4,
      user:    answer.reciever,
      sender:  answer.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      message: "#{answer.user.login_name}さんから回答がありました。",
      read:    false
    )
  end

  def self.post_announcement(announce, reciever)
    Notification.create!(
      kind:    5,
      user:    reciever,
      sender:  announce.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(announce),
      message: "#{announce.user.login_name}さんからお知らせです。",
      read:    false
    )
  end

  def self.came_question(question, reciever)
    Notification.create!(
      kind:    6,
      user:    reciever,
      sender:  question.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(question),
      message: "#{question.user.login_name}さんから質問がきました。",
      read:    false
    )
  end

  def self.report_submitted(report, reciever, message)
    Notification.create!(
      kind:    7,
      user:    reciever,
      sender:  report.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(report),
      message: message,
      read:    false
    )
  end

  def self.watching_notification(watchable, reciever)
    Notification.create!(
      kind:    8,
      user:    reciever,
      sender:  watchable.user,
      path:    Rails.application.routes.url_helpers.polymorphic_path(watchable),
      message: "あなたがウォッチしている【 #{watchable.title} 】にコメントが投稿されました。",
      read:    false
    )
  end

  def self.retired(sender, reciever)
    Notification.create!(
      kind:    9,
      user:    reciever,
      sender:  sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(sender),
      message: "#{sender.login_name}さんが退会しました。",
      read:    false
    )
  end
end
