# frozen_string_literal: true

class ProductAuthorWatcher
  def call(product)
    Watch.create!(user: product.user, watchable: product)
  end
end
