# frozen_string_literal: true

class CommentNotifierForAdmin
  def call(payload)
    comment = payload[:comment]
    return if comment.nil?

    User.admins.each do |admin_user|
      next if comment.sender == admin_user

      commentable_path = Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)
      ActivityDelivery.with(
        comment:,
        receiver: admin_user,
        message: "#{comment.commentable.user.login_name}さんの相談部屋で#{comment.sender.login_name}さんからコメントが届きました。",
        link: "#{commentable_path}#latest-comment"
      ).notify(:came_comment)
    end
  end
end
