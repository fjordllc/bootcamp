# frozen_string_literal: true

class ProductAuthorWatcher
  def call(payload)
    product = payload[:product]
    Watch.create!(user: product.user, watchable: product)
  end
end
