# frozen_string_literal: true

class CommentNotifier
  def call(_name, _started, _finished, _id, payload)
    comment = payload[:comment]
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
