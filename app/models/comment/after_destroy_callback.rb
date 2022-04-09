# frozen_string_literal: true

class Comment::AfterDestroyCallback
  def after_destroy(comment)
    return unless comment.commentable.instance_of?(Product)

    comment.commentable.delete_last_commented_at
    comment.commentable.delete_commented_at
    delete_product_cache(comment.commentable.id)

    return unless comment.latest?

    delete_assigned_and_unreplied_product_count_cache(comment)
  end

  private

  def delete_product_cache(product_id)
    Rails.cache.delete "/model/product/#{product_id}/last_commented_user"
  end

  def delete_assigned_and_unreplied_product_count_cache(comment)
    product = comment.commentable

    return unless product.checker_id.present? && product.replied_status_changed?(comment.previous&.user_id, comment.user_id)

    Cache.delete_self_assigned_no_replied_product_count(product.checker_id)
  end
end
