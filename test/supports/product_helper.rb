# frozen_string_literal: true

module ProductHelper
  def delete_most_unchecked_products!
    products = Product.unchecked
                      .not_wip
                      .ascending_by_date_of_publishing_and_id

    products[2..products.size].each(&:delete)
  end

  def delete_most_unassigned_products!
    products = Product.unassigned
                      .not_wip
                      .ascending_by_date_of_publishing_and_id

    products[2..products.size].each(&:delete)
  end

  def create_checked_product(user, practice)
    product = Product.create(user:, practice:, body: 'test')
    Check.create(user:, checkable: product)
  end

  # Helper method to ensure product ID is valid before using it
  def ensure_valid_product(product)
    raise ArgumentError, 'Product ID is nil or invalid' if product.nil? || product.id.nil?

    product
  end
end
