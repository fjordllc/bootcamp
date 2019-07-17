# frozen_string_literal: true

class InnerNotification < ApplicationRecord
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
    first_report:  7,
    watching:      8
  }

  scope :unreads, -> {
    into_one = select(:path).group(:path).maximum(:created_at)
    where(read: false, created_at: into_one.values).order(created_at: :desc)
  }

  scope :with_avatar, -> { preload(sender: { avatar_attachment: :blob }) }

  def self.came_comment(comment, reciever, message)
    InnerNotification.create!(
      kind:    0,
      user:    reciever,
      sender:  comment.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      message: message,
      read:    false
    )
  end

  def self.checked(check)
    InnerNotification.create!(
      kind:    1,
      user:    check.reciever,
      sender:  check.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
      message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      read:    false
    )
  end

  def self.mentioned(comment, reciever)
    InnerNotification.create!(
      kind:    2,
      user:    reciever,
      sender:  comment.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      message: "#{comment.sender.login_name}さんからメンションがきました。",
      read:    false
    )
  end

  def self.submitted(subject, reciever, message)
    InnerNotification.create!(
      kind:    3,
      user:    reciever,
      sender:  subject.user,
      path:    Rails.application.routes.url_helpers.polymorphic_path(subject),
      message: message,
      read:    false
    )
  end

  def self.came_answer(answer)
    InnerNotification.create!(
      kind:    4,
      user:    answer.reciever,
      sender:  answer.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      message: "#{answer.user.login_name}さんから回答がありました。",
      read:    false
    )
  end

  def self.post_announcement(announce, reciever)
    InnerNotification.create!(
      kind:    5,
      user:    reciever,
      sender:  announce.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(announce),
      message: "#{announce.user.login_name}さんからお知らせです。",
      read:    false
    )
  end

  def self.came_question(question, reciever)
    InnerNotification.create!(
      kind:    6,
      user:    reciever,
      sender:  question.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(question),
      message: "#{question.user.login_name}さんから質問がありました。",
      read:    false
    )
  end

  def self.first_report(report, reciever)
    InnerNotification.create!(
      kind:    7,
      user:    reciever,
      sender:  report.sender,
      path:    Rails.application.routes.url_helpers.polymorphic_path(report),
      message: "#{report.user.login_name}さんがはじめての日報を書きました！",
      read:    false
    )
  end

  def self.watching_notification(watchable, reciever)
    InnerNotification.create!(
      kind:    8,
      user:    reciever,
      sender:  watchable.user,
      path:    Rails.application.routes.url_helpers.polymorphic_path(watchable),
      message: "あなたがウォッチしている【 #{watchable.title} 】にコメントが投稿されました。",
      read:    false
    )
  end
end
