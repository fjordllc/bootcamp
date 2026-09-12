# frozen_string_literal: true

class ProductAssignment
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
end
