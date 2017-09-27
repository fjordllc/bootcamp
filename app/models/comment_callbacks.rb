class CommentCallbacks
  def after_create(comment)
    if comment.sender != comment.reciever
      Notification.came_comment(comment)
    end
  end
end
