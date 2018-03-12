class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: "User"

  enum kind: {
    came_comment: 0,
    checked:      1,
    mentioned:    2,
    submitted:    3
  }

  scope :unreads, -> { where(read: false).order(created_at: :desc) }

  def self.came_comment(comment)
    Notification.create!(
      kind:    0,
      user:    comment.reciever,
      sender:  comment.sender,
      path:    comment.commentable.path,
      message: "#{comment.sender.login_name}さんからコメントが届きました。",
      read:    false
    )
  end

  def self.checked(check)
    Notification.create!(
      kind:    1,
      user:    check.reciever,
      sender:  check.sender,
      path:    check.checkable.path,
      message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      read:    false
    )
  end

  def self.mentioned(comment, reciever)
    Notification.create!(
      kind:    2,
      user:    reciever,
      sender:  comment.sender,
      path:    comment.commentable.path,
      message: "#{comment.sender.login_name}さんからメンションがきました。",
      read:    false
    )
  end

  def self.submitted(subject, reciever)
    Notification.create!(
      kind:    3,
      user:    reciever,
      sender:  subject.user,
      path:    subject.path,
      message: "#{subject.user.login_name}さんが提出しました。",
      read:    false
    )
  end
end
