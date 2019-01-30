# frozen_string_literal: true

module CommentsHelper
  def user_comments_page?
    controller_path == "users/comments" && action_name == "index"
  end

  def comment_title(commentable)
    if commentable.is_a?(Report)
      commentable.title
    elsif commentable.is_a?(Product)
      commentable.practice.title
    end
  end
end
