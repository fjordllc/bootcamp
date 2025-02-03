# frozen_string_literal: true

class Products::ProductCheckerComponent < ViewComponent::Base
  def initialize(checker_id:, checker_name:, current_user_id:, product_id:, checker_avatar:)
    @checker_id = checker_id
    @checker_name = checker_name
    @current_user_id = current_user_id
    @product_id = product_id
    @checker_avatar = checker_avatar
  end

  def button_label
    @checker_id ? '担当から外れる' : '担当する'
  end
end
