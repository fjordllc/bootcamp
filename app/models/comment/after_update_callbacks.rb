# frozen_string_literal: true

class Comment::AfterUpdateCallbacks
  def after_update(comment)
    return unless comment.commentable.instance_of?(Product)

    update_last_commented_at(comment)
    update_commented_at(comment)
  end

  private

  def update_last_commented_at(comment)
    product = Product.find(comment.commentable.id)
    if comment.user.mentor
      product.mentor_last_commented_at = comment.updated_at
    elsif comment.user == product.user
      product.self_last_commented_at = comment.updated_at
    end
    product.save!
  end

  def update_commented_at(comment)
    comment.commentable.update!(commented_at: comment.updated_at)
  end
end
