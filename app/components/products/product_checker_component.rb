# frozen_string_literal: true

class Products::ProductCheckerComponent < ViewComponent::Base
  def initialize(checker_id:, checker_name:, checker_avatar:, current_user_id:, product_id:)
    @checker_id = checker_id
    @checker_name = checker_name
    @checker_avatar = checker_avatar
    @current_user_id = current_user_id
    @product_id = product_id
  end
end
