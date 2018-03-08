module CommentsHelper
  def commentable_url(comment)
    case comment.commentable
    when Report
      polymorphic_url(comment.commentable)
    when Product
      polymorphic_url([comment.commentable.practice, comment.commentable])
    end
  end

  def comment_form_object(comment)
    case comment.commentable
    when Report
      [comment.commentable, comment]
    when Product
      [comment.commentable.practice, comment.commentable, comment]
    end
  end
end
