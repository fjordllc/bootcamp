class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :sender, class_name: "User"

  enum kind: {
      came_comment: 0,
  }

  scope :unreads, -> { where(read: false) }

  def self.came_comment(comment)
    Notification.create!(
        kind:    0,
        user:    comment.reciever,
        sender:  comment.sender,
        path:    Rails.application.routes.url_helpers.report_path(comment.report),
        message: "#{comment.sender.login_name}さんからコメントが届きました。",
        read:    false
    )
  end
end
