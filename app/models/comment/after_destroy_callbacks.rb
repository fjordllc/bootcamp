# frozen_string_literal: true

class Comment::AfterDestroyCallbacks
  def after_destroy(comment)
    return unless comment.commentable.instance_of?(Product)

    delete_last_commented_at(comment.commentable.id)
    delete_commented_at(comment)
    delete_product_cache(comment.commentable.id)

    return unless comment.latest?

    delete_assigned_and_unreplied_product_count_cache(comment)
  end

  private

  def reset_last_commented_at(product)
    product.mentor_last_commented_at = nil
    product.self_last_commented_at = nil
  end

  def delete_last_commented_at(product_id)
    product = Product.find(product_id)

    reset_last_commented_at(product)

    product.comments.each do |comment|
      if comment.user.mentor
        product.mentor_last_commented_at = comment.updated_at
      elsif comment.user == product.user
        product.self_last_commented_at = comment.updated_at
      end
    end
    product.save!
  end

  def delete_commented_at(comment)
    last_comment = comment.commentable.comments.last
    comment.commentable.commented_at = last_comment ? last_comment.updated_at : nil
    comment.commentable.save!
  end

  def delete_product_cache(product_id)
    Rails.cache.delete "/model/product/#{product_id}/last_commented_user"
  end
end
