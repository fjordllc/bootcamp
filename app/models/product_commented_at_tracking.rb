# frozen_string_literal: true

class ProductCommentedAtTracking
  def initialize(product)
    @product = product
  end

  def replied_status_changed?(previous_commented_user_id, current_commented_user_id)
    is_replied_by_checker_previous = @product.checker_id == previous_commented_user_id
    is_replied_by_checker_current = @product.checker_id == current_commented_user_id

    is_replied_by_checker_previous != is_replied_by_checker_current
  end

  def update_last_commented_at(comment)
    if comment
      if comment.user.mentor
        @product.update_columns(mentor_last_commented_at: comment.updated_at) # rubocop:disable Rails/SkipsModelValidations
      elsif comment.user == @product.user
        @product.update_columns(self_last_commented_at: comment.updated_at) # rubocop:disable Rails/SkipsModelValidations
      end
    else
      @product.update_columns(mentor_last_commented_at: nil, self_last_commented_at: nil) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def update_commented_at(comment)
    @product.update_columns(commented_at: comment&.updated_at) # rubocop:disable Rails/SkipsModelValidations
  end

  def delete_last_commented_at
    update_last_commented_at(@product.comments.last)
  end

  def delete_commented_at
    update_commented_at(@product.comments.last)
  end

  def self.add_latest_commented_at
    Product.all.includes(:comments).find_each do |product|
      next if product.comments.blank?

      product.update!(commented_at: product.comments.last.updated_at)
    end
  end
end
