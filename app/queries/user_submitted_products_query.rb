# frozen_string_literal: true

class UserSubmittedProductsQuery
  def initialize(product)
    @product = product
  end

  def call
    @product.user
            .products
            .includes(:practice, :user, :comments, :checks, comments: :user)
            .not_wip
            .order(published_at: :desc)
  end
end
