# frozen_string_literal: true

class ProductChecker
  def initialize(product)
    @product = product
  end

  def other_checker_exists?(user_id)
    @product.checker_id.present? && @product.checker_id != user_id
  end

  def unassigned?
    @product.checker_id.nil?
  end

  def checker_name
    @product.checker&.login_name
  end

  def checker_avatar
    @product.checker&.avatar_url
  end

  def change_learning_status(status)
    learning = Learning.find_or_initialize_by(
      user_id: @product.user.id,
      practice_id: @product.practice.id
    )
    learning.update!(status:)
  end

  def last_commented_user
    Rails.cache.fetch "/model/product/#{@product.id}/last_commented_user" do
      @product.commented_users.last
    end
  end
end
