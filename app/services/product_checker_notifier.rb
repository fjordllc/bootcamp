# frozen_string_literal: true

class ProductCheckerNotifier
  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  def call
    checker_id = @product.checker_id

    return unless checker_id &&
                  @current_user.admin_or_mentor_login? &&
                  checker_id != @current_user.id &&
                  !@product.wip?

    ActivityDelivery.with(
      product: @product,
      receiver: User.find(checker_id)
    ).notify(:assigned_as_checker)
  end
end
