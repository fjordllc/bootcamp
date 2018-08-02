module ProductsHelper
  def user_passed?
    product = Product.find_by(user_id: current_user.id, practice_id: @practice.id)
    if product
      product.checks.any?
    else
    end
  end
end
