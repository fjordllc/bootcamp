# frozen_string_literal: true

class Comment::AfterUpdateCallback
  def after_update(comment)
    return unless comment.commentable.instance_of?(Product)

    comment.commentable.commented_at_tracking.update_last_commented_at(comment)
    comment.commentable.commented_at_tracking.update_commented_at(comment)
  end
end
