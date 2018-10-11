# frozen_string_literal: true

module CommentsHelper
  def commentable_url(comment)
    case comment.commentable
    when Product
      polymorphic_url([comment.commentable.practice, comment.commentable])
    else
      polymorphic_url(comment.commentable)
    end
  end
end
