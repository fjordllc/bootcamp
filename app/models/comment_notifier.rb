# frozen_string_literal: true

class CommentNotifier
  def call(comment)
    return if comment.nil?

    commentable_path = Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)
    ActivityDelivery.with(
      comment:,
      receiver: comment.receiver,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      link: "#{commentable_path}#latest-comment"
    ).notify(:came_comment)
  end
end
