# frozen_string_literal: true

module ProductsHelper
  def not_responded_product_count
    Rails.cache.fetch "not_responded_product_count" do
      Product.not_responded_products.count
    end
  end
end
